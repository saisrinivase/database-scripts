/*
PostgreSQL DBA Script: Partition Sme Decision Scorecard
Purpose: Provide an SME-style partitioning scorecard using size, data-span, write pressure, and scan behavior.
Area: Partitioning
Usage: Run after ANALYZE; use output to decide if partitioning is required, recommended, or low priority.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH base AS (
    SELECT
        s.relid,
        s.schemaname AS schema_name,
        s.relname AS table_name,
        pg_total_relation_size(s.relid) AS total_bytes,
        round(pg_total_relation_size(s.relid) / 1024.0 / 1024.0 / 1024.0, 2) AS total_size_gb,
        s.n_live_tup::bigint AS estimated_live_rows,
        (s.n_tup_ins + s.n_tup_upd + s.n_tup_del)::bigint AS write_volume,
        s.seq_scan,
        s.idx_scan,
        s.seq_tup_read,
        c.relispartition
    FROM pg_stat_user_tables s
    JOIN pg_class c
      ON c.oid = s.relid
),
temporal_cols AS (
    SELECT
        b.relid,
        b.schema_name,
        b.table_name,
        a.attname AS temporal_column,
        format_type(a.atttypid, a.atttypmod) AS temporal_type,
        ps.histogram_bounds::text AS histogram_text
    FROM base b
    JOIN pg_attribute a
      ON a.attrelid = b.relid
     AND a.attnum > 0
     AND NOT a.attisdropped
    LEFT JOIN pg_stats ps
      ON ps.schemaname = b.schema_name
     AND ps.tablename = b.table_name
     AND ps.attname = a.attname
    WHERE a.atttypid IN (
        'date'::regtype,
        'timestamp without time zone'::regtype,
        'timestamp with time zone'::regtype
    )
),
parsed_temporal AS (
    SELECT
        relid,
        schema_name,
        table_name,
        temporal_column,
        temporal_type,
        CASE
            WHEN histogram_text IS NULL OR histogram_text IN ('', '{}') THEN NULL::text[]
            ELSE string_to_array(trim(both '{}' FROM histogram_text), ',')
        END AS hist_arr
    FROM temporal_cols
),
temporal_span AS (
    SELECT
        relid,
        schema_name,
        table_name,
        temporal_column,
        temporal_type,
        NULLIF(btrim(hist_arr[1], '"'), '') AS min_bound_text,
        NULLIF(btrim(hist_arr[array_length(hist_arr, 1)], '"'), '') AS max_bound_text,
        CASE
            WHEN hist_arr IS NULL OR array_length(hist_arr, 1) < 2 THEN NULL::numeric
            WHEN temporal_type = 'date' THEN round(
                extract(
                    epoch FROM (
                        (NULLIF(btrim(hist_arr[array_length(hist_arr, 1)], '"'), '')::date)::timestamp
                        - (NULLIF(btrim(hist_arr[1], '"'), '')::date)::timestamp
                    )
                ) / 31557600.0,
                2
            )
            WHEN temporal_type = 'timestamp with time zone' THEN round(
                extract(
                    epoch FROM (
                        NULLIF(btrim(hist_arr[array_length(hist_arr, 1)], '"'), '')::timestamptz
                        - NULLIF(btrim(hist_arr[1], '"'), '')::timestamptz
                    )
                ) / 31557600.0,
                2
            )
            ELSE round(
                extract(
                    epoch FROM (
                        NULLIF(btrim(hist_arr[array_length(hist_arr, 1)], '"'), '')::timestamp
                        - NULLIF(btrim(hist_arr[1], '"'), '')::timestamp
                    )
                ) / 31557600.0,
                2
            )
        END AS approx_span_years
    FROM parsed_temporal
),
best_temporal AS (
    SELECT DISTINCT ON (relid)
        relid,
        temporal_column,
        temporal_type,
        min_bound_text,
        max_bound_text,
        approx_span_years
    FROM temporal_span
    ORDER BY relid, approx_span_years DESC NULLS LAST, temporal_column
),
widest_col AS (
    SELECT
        schemaname AS schema_name,
        tablename AS table_name,
        attname AS widest_column,
        avg_width,
        row_number() OVER (
            PARTITION BY schemaname, tablename
            ORDER BY avg_width DESC NULLS LAST, attname
        ) AS rn
    FROM pg_stats
    WHERE schemaname !~ '^pg_'
      AND schemaname <> 'information_schema'
),
ranked AS (
    SELECT
        b.schema_name,
        b.table_name,
        b.total_bytes,
        b.total_size_gb,
        b.estimated_live_rows,
        b.write_volume,
        b.seq_scan,
        b.idx_scan,
        b.seq_tup_read,
        coalesce(bt.temporal_column, '(none)') AS recommended_partition_key,
        bt.temporal_type,
        bt.min_bound_text,
        bt.max_bound_text,
        bt.approx_span_years,
        coalesce(w.widest_column, '(unknown)') AS widest_column,
        coalesce(w.avg_width, 0) AS widest_column_avg_width,
        (
            CASE
                WHEN b.total_size_gb >= 1500 THEN 45
                WHEN b.total_size_gb >= 500 THEN 35
                WHEN b.total_size_gb >= 100 THEN 25
                WHEN b.total_size_gb >= 20 THEN 15
                WHEN b.total_size_gb >= 5 THEN 8
                ELSE 0
            END
            + CASE
                WHEN coalesce(bt.approx_span_years, 0) >= 10 THEN 25
                WHEN coalesce(bt.approx_span_years, 0) >= 5 THEN 16
                WHEN coalesce(bt.approx_span_years, 0) >= 3 THEN 10
                WHEN coalesce(bt.approx_span_years, 0) >= 1 THEN 5
                ELSE 0
            END
            + CASE
                WHEN b.write_volume >= 100000000 THEN 15
                WHEN b.write_volume >= 10000000 THEN 10
                WHEN b.write_volume >= 1000000 THEN 5
                ELSE 0
            END
            + CASE
                WHEN b.seq_tup_read >= 100000000 THEN 10
                WHEN b.seq_tup_read >= 10000000 THEN 6
                WHEN b.seq_scan > b.idx_scan AND b.seq_tup_read >= 1000000 THEN 4
                ELSE 0
            END
            + CASE
                WHEN bt.temporal_column IS NOT NULL THEN 5
                ELSE 0
            END
        )::int AS partition_readiness_score
    FROM base b
    LEFT JOIN best_temporal bt
      ON bt.relid = b.relid
    LEFT JOIN widest_col w
      ON w.schema_name = b.schema_name
     AND w.table_name = b.table_name
     AND w.rn = 1
    WHERE NOT b.relispartition
)
SELECT
    schema_name,
    table_name,
    total_size_gb,
    estimated_live_rows,
    write_volume,
    seq_scan,
    idx_scan,
    seq_tup_read,
    recommended_partition_key,
    temporal_type,
    min_bound_text AS approx_min_time,
    max_bound_text AS approx_max_time,
    approx_span_years,
    widest_column,
    widest_column_avg_width,
    partition_readiness_score,
    CASE
        WHEN partition_readiness_score >= 65 THEN 'REQUIRED_NOW'
        WHEN partition_readiness_score >= 45 THEN 'STRONGLY_RECOMMENDED'
        WHEN partition_readiness_score >= 30 THEN 'EVALUATE_WITH_EXPLAIN'
        ELSE 'LOW_PRIORITY'
    END AS recommendation,
    CASE
        WHEN recommended_partition_key = '(none)' THEN 'No temporal key found; evaluate HASH/LIST partitioning only if access pattern needs it.'
        WHEN coalesce(approx_span_years, 0) >= 10 AND total_size_gb >= 500 THEN 'YEARLY parent with monthly partitions for hot recent data.'
        WHEN coalesce(approx_span_years, 0) >= 5 THEN 'MONTHLY partitions.'
        WHEN coalesce(approx_span_years, 0) >= 1 THEN 'WEEKLY or MONTHLY partitions depending on retention window.'
        ELSE 'Partitioning mainly for retention/isolation, not pruning benefit.'
    END AS suggested_granularity,
    CASE
        WHEN partition_readiness_score >= 45 THEN
            '1) Confirm partition key in top queries; 2) Create partitioned shadow table; 3) Backfill in chunks; 4) Add local indexes per partition; 5) Swap with minimal downtime; 6) Automate future partition creation and retention.'
        WHEN partition_readiness_score >= 30 THEN
            '1) Test representative queries with EXPLAIN; 2) Compare index-only tuning vs partitioning; 3) Partition only if pruning or retention gains are material.'
        ELSE
            'No immediate partitioning project required. Re-check quarterly or after major data growth.'
    END AS developer_action_steps,
    'size_gb='
    || to_char(total_size_gb, 'FM9999999990.00')
    || '; span_years='
    || coalesce(approx_span_years::text, 'n/a')
    || '; writes='
    || write_volume::text
    || '; seq_scan='
    || seq_scan::text
    || '; idx_scan='
    || idx_scan::text
    || '; seq_tup_read='
    || seq_tup_read::text AS factor_breakdown
FROM ranked
ORDER BY partition_readiness_score DESC, total_size_gb DESC, schema_name, table_name;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture file: /tmp/partition_new_outputs_20260218/05.out.txt
--
--    schema_name    |          table_name           | total_size_gb | estimated_live_rows | write_volume | seq_scan | idx_scan | seq_tup_read | recommended_partition_key |        temporal_type        |      approx_min_time       |      approx_max_time       | approx_span_years | widest_column | widest_column_avg_width | partition_readiness_score |    recommendation     |                                  suggested_granularity                                  |                                                                                                   developer_action_steps                                                                                                    |                                            factor_breakdown                                            
-- ------------------+-------------------------------+---------------+---------------------+--------------+----------+----------+--------------+---------------------------+-----------------------------+----------------------------+----------------------------+-------------------+---------------+-------------------------+---------------------------+-----------------------+-----------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------
--  partition_lab    | fact_events_10y_unpartitioned |          5.00 |             4500006 |      4500000 |        4 |        0 |      4500000 | event_date                | date                        | 2016-02-18                 | 2026-02-18                 |             10.00 | payload       |                    1028 |                        47 | STRONGLY_RECOMMENDED  | MONTHLY partitions.                                                                     | 1) Confirm partition key in top queries; 2) Create partitioned shadow table; 3) Backfill in chunks; 4) Add local indexes per partition; 5) Swap with minimal downtime; 6) Automate future partition creation and retention. | size_gb=5.00; span_years=10.00; writes=4500000; seq_scan=4; idx_scan=0; seq_tup_read=4500000
--  public           | pgbench_accounts              |         29.54 |           200000029 |    205332823 |        2 | 10665646 |    200000000 | (none)                    |                             |                            |                            |                   | filler        |                      85 |                        40 | EVALUATE_WITH_EXPLAIN | No temporal key found; evaluate HASH/LIST partitioning only if access pattern needs it. | 1) Test representative queries with EXPLAIN; 2) Compare index-only tuning vs partitioning; 3) Partition only if pruning or retention gains are material.                                                                    | size_gb=29.54; span_years=n/a; writes=205332823; seq_scan=2; idx_scan=10665646; seq_tup_read=200000000
--  public           | pgbench_history               |          0.26 |             5331130 |      5332823 |        0 |          |            0 | mtime                     | timestamp without time zone | 2026-01-31 21:39:05.921956 | 2026-01-31 21:49:05.844327 |              0.00 | mtime         |                       8 |                        10 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | 
--  migration_v2_lab | partitioned_events            |          0.00 |                   0 |            0 |        0 |        0 |            0 | event_date                | date                        | 2025-01-01                 | 2026-12-01                 |              1.91 | event_payload |                      33 |                        10 | LOW_PRIORITY          | WEEKLY or MONTHLY partitions depending on retention window.                             | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.00; span_years=1.91; writes=0; seq_scan=0; idx_scan=0; seq_tup_read=0
--  migration_v2_lab | order_fact                    |          0.05 |              300000 |       300000 |       11 |        0 |      1200000 | created_at                | timestamp with time zone    |                            |                            |                   | search_text   |                      25 |                         9 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.05; span_years=n/a; writes=300000; seq_scan=11; idx_scan=0; seq_tup_read=1200000
--  migration_v2_lab | amount_mapping_risk           |          0.02 |              120000 |       240000 |        4 |        0 |       360000 | created_at                | timestamp with time zone    |                            |                            |                   | created_at    |                       8 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.02; span_years=n/a; writes=240000; seq_scan=4; idx_scan=0; seq_tup_read=360000
--  migration_v2_lab | child_events                  |          0.02 |              250000 |       250000 |        3 |        0 |       250000 | event_ts                  | timestamp with time zone    |                            |                            |                   | account_id    |                       8 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.02; span_years=n/a; writes=250000; seq_scan=3; idx_scan=0; seq_tup_read=250000
--  migration_v2_lab | stale_stats_table             |          0.02 |              180000 |       180000 |        1 |        0 |            0 | created_at                | timestamp with time zone    |                            |                            |                   | payload       |                      65 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.02; span_years=n/a; writes=180000; seq_scan=1; idx_scan=0; seq_tup_read=0
--  migration_v1_lab | child_transactions            |          0.01 |              120000 |       120000 |        2 |        0 |       120000 | created_at                | timestamp with time zone    |                            |                            |                   | account_id    |                       8 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.01; span_years=n/a; writes=120000; seq_scan=2; idx_scan=0; seq_tup_read=120000
--  migration_v1_lab | product_catalog               |          0.01 |               50000 |        50000 |        3 |        0 |       100000 | created_at                | timestamp with time zone    |                            |                            |                   | sku           |                       9 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.01; span_years=n/a; writes=50000; seq_scan=3; idx_scan=0; seq_tup_read=100000
--  migration_v2_lab | bloat_pressure_table          |          0.01 |               42000 |       138000 |        1 |        1 |            0 | created_at                | timestamp with time zone    |                            |                            |                   | payload       |                      87 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.01; span_years=n/a; writes=138000; seq_scan=1; idx_scan=1; seq_tup_read=0
--  migration_v2_lab | sales_catalog                 |          0.01 |              120000 |       120000 |        3 |        0 |       240000 | created_at                | timestamp with time zone    |                            |                            |                   | item_ref      |                      11 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.01; span_years=n/a; writes=120000; seq_scan=3; idx_scan=0; seq_tup_read=240000
--  public           | pgbench_branches              |          0.01 |                2000 |      5334823 |        3 |  5332823 |         6000 | (none)                    |                             |                            |                            |                   | bbalance      |                       4 |                         5 | LOW_PRIORITY          | No temporal key found; evaluate HASH/LIST partitioning only if access pattern needs it. | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.01; span_years=n/a; writes=5334823; seq_scan=3; idx_scan=5332823; seq_tup_read=6000
--  dba_metrics      | connection_snapshots          |          0.00 |                   9 |            9 |        0 |          |            0 | captured_at               | timestamp with time zone    |                            |                            |                   | (unknown)     |                       0 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | 
--  dba_metrics      | database_size_snapshots       |          0.00 |                  21 |           21 |        3 |          |           42 | captured_at               | timestamp with time zone    |                            |                            |                   | (unknown)     |                       0 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | 
--  dba_metrics      | index_size_snapshots          |          0.00 |                  81 |           81 |        0 |          |            0 | captured_at               | timestamp with time zone    |                            |                            |                   | index_name    |                      23 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | 
--  dba_metrics      | table_size_snapshots          |          0.00 |                  89 |           89 |        3 |          |          171 | captured_at               | timestamp with time zone    |                            |                            |                   | table_name    |                      18 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | 
--  dba_metrics      | wal_snapshots                 |          0.00 |                   3 |            3 |        0 |          |            0 | captured_at               | timestamp with time zone    |                            |                            |                   | (unknown)     |                       0 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | 
--  migration_v1_lab | orders_no_pk                  |          0.00 |               10000 |        10000 |        1 |        0 |        10000 | created_at                | timestamp with time zone    |                            |                            |                   | customer_name |                      13 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.00; span_years=n/a; writes=10000; seq_scan=1; idx_scan=0; seq_tup_read=10000
--  migration_v2_lab | customer_staging_no_pk        |          0.00 |               60000 |        60000 |        1 |        0 |        60000 | created_at                | timestamp with time zone    |                            |                            |                   | customer_name |                      10 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.00; span_years=n/a; writes=60000; seq_scan=1; idx_scan=0; seq_tup_read=60000
--  migration_v2_lab | issue_manifest                |          0.00 |                  11 |           11 |        1 |        0 |            0 | seeded_at                 | timestamp with time zone    |                            |                            |                   | (unknown)     |                       0 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.00; span_years=n/a; writes=11; seq_scan=1; idx_scan=0; seq_tup_read=0
--  migration_v2_lab | mv_daily_order_volume         |          0.00 |                   1 |            2 |        0 |          |            0 | order_date                | date                        |                            |                            |                   | (unknown)     |                       0 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | 
--  migration_v2_lab | parent_accounts               |          0.00 |               50000 |        50000 |        1 |   250000 |            0 | created_at                | timestamp with time zone    |                            |                            |                   | account_name  |                      10 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.00; span_years=n/a; writes=50000; seq_scan=1; idx_scan=250000; seq_tup_read=0
--  migration_v2_lab | quoted_orders                 |          0.00 |                5000 |         5000 |        1 |        0 |            0 | created_at                | timestamp with time zone    |                            |                            |                   | notes         |                      16 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.00; span_years=n/a; writes=5000; seq_scan=1; idx_scan=0; seq_tup_read=0
--  migration_v2_lab | trigger_audit_demo            |          0.00 |                   0 |            0 |        1 |        0 |            0 | updated_at                | timestamp with time zone    |                            |                            |                   | (unknown)     |                       0 |                         5 | LOW_PRIORITY          | Partitioning mainly for retention/isolation, not pruning benefit.                       | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.00; span_years=n/a; writes=0; seq_scan=1; idx_scan=0; seq_tup_read=0
--  public           | pgbench_tellers               |          0.00 |               20000 |      5352823 |        1 |  5332823 |        20000 | (none)                    |                             |                            |                            |                   | bid           |                       4 |                         5 | LOW_PRIORITY          | No temporal key found; evaluate HASH/LIST partitioning only if access pattern needs it. | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.00; span_years=n/a; writes=5352823; seq_scan=1; idx_scan=5332823; seq_tup_read=20000
--  migration_v1_lab | stale_stats_table             |          0.01 |               60000 |        60000 |        1 |        0 |            0 | (none)                    |                             |                            |                            |                   | payload       |                      65 |                         0 | LOW_PRIORITY          | No temporal key found; evaluate HASH/LIST partitioning only if access pattern needs it. | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.01; span_years=n/a; writes=60000; seq_scan=1; idx_scan=0; seq_tup_read=0
--  migration_v2_lab | customer_contact_compat       |          0.01 |               90000 |       141429 |        4 |        0 |       270000 | (none)                    |                             |                            |                            |                   | email         |                      20 |                         0 | LOW_PRIORITY          | No temporal key found; evaluate HASH/LIST partitioning only if access pattern needs it. | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.01; span_years=n/a; writes=141429; seq_scan=4; idx_scan=0; seq_tup_read=270000
--  migration_v1_lab | dml_bloat_table               |          0.00 |               12000 |        38000 |        1 |        1 |            0 | (none)                    |                             |                            |                            |                   | payload       |                     109 |                         0 | LOW_PRIORITY          | No temporal key found; evaluate HASH/LIST partitioning only if access pattern needs it. | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.00; span_years=n/a; writes=38000; seq_scan=1; idx_scan=1; seq_tup_read=0
--  migration_v1_lab | parent_accounts               |          0.00 |               10000 |        10000 |        1 |   120000 |            0 | (none)                    |                             |                            |                            |                   | account_name  |                       9 |                         0 | LOW_PRIORITY          | No temporal key found; evaluate HASH/LIST partitioning only if access pattern needs it. | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.00; span_years=n/a; writes=10000; seq_scan=1; idx_scan=120000; seq_tup_read=0
--  migration_v1_lab | sales_orders                  |          0.00 |                1000 |         1000 |        1 |        0 |            0 | (none)                    |                             |                            |                            |                   | notes         |                      15 |                         0 | LOW_PRIORITY          | No temporal key found; evaluate HASH/LIST partitioning only if access pattern needs it. | No immediate partitioning project required. Re-check quarterly or after major data growth.                                                                                                                                  | size_gb=0.00; span_years=n/a; writes=1000; seq_scan=1; idx_scan=0; seq_tup_read=0
-- (31 rows)
-- 
-- SAMPLE_OUTPUT_END
