/*
PostgreSQL DBA Script: Partition Target Table Deep Advisor
Purpose: Deep-dive partition advisor for a specific table and time column, with SME decision score and developer action steps.
Area: Partitioning
Usage: Edit the params CTE near the bottom when targeting a different table. Works in pgAdmin and psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
CREATE OR REPLACE FUNCTION pg_temp.partition_target_table_advisor(
    p_schema text,
    p_table text,
    p_time_column text,
    p_hot_window_months int
)
RETURNS TABLE (
    schema_name text,
    table_name text,
    total_size_gb numeric,
    estimated_live_rows bigint,
    write_volume bigint,
    seq_scan bigint,
    idx_scan bigint,
    seq_to_idx_ratio numeric,
    selected_time_column text,
    min_time_value timestamptz,
    max_time_value timestamptz,
    span_years numeric,
    partition_readiness_score int,
    recommendation text,
    suggested_granularity text,
    developer_action_steps text,
    decision_rationale text
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_relid oid;
    v_total_bytes bigint := 0;
    v_live_rows bigint := 0;
    v_write_volume bigint := 0;
    v_seq_scan bigint := 0;
    v_idx_scan bigint := 0;
    v_seq_tup_read bigint := 0;
    v_time_column text := nullif(btrim(p_time_column), '');
    v_time_type regtype;
    v_min_ts timestamptz;
    v_max_ts timestamptz;
    v_nonnull_rows bigint := 0;
    v_span_years numeric := NULL;
    v_score int := 0;
    v_reco text;
    v_grain text;
    v_steps text;
    v_ratio numeric;
    v_reason text;
BEGIN
    SELECT
        c.oid,
        pg_total_relation_size(c.oid),
        coalesce(s.n_live_tup::bigint, 0),
        coalesce((s.n_tup_ins + s.n_tup_upd + s.n_tup_del)::bigint, 0),
        coalesce(s.seq_scan::bigint, 0),
        coalesce(s.idx_scan::bigint, 0),
        coalesce(s.seq_tup_read::bigint, 0)
    INTO
        v_relid,
        v_total_bytes,
        v_live_rows,
        v_write_volume,
        v_seq_scan,
        v_idx_scan,
        v_seq_tup_read
    FROM pg_class c
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    LEFT JOIN pg_stat_user_tables s
      ON s.relid = c.oid
    WHERE n.nspname = p_schema
      AND c.relname = p_table
      AND c.relkind IN ('r', 'p');

    IF v_relid IS NULL THEN
        RETURN QUERY
        SELECT
            p_schema,
            p_table,
            0::numeric,
            0::bigint,
            0::bigint,
            0::bigint,
            0::bigint,
            NULL::numeric,
            coalesce(v_time_column, '(none)'),
            NULL::timestamptz,
            NULL::timestamptz,
            NULL::numeric,
            0,
            'TABLE_NOT_FOUND',
            'N/A',
            'Verify schema/table name, then rerun.',
            'Target table does not exist in current database.';
        RETURN;
    END IF;

    IF v_time_column IS NULL THEN
        SELECT a.attname
        INTO v_time_column
        FROM pg_attribute a
        WHERE a.attrelid = v_relid
          AND a.attnum > 0
          AND NOT a.attisdropped
          AND a.atttypid IN (
                'date'::regtype,
                'timestamp without time zone'::regtype,
                'timestamp with time zone'::regtype
          )
        ORDER BY
            CASE
                WHEN a.attname ~* '(event|created|txn|trans|business|date|time)' THEN 0
                ELSE 1
            END,
            a.attnum
        LIMIT 1;
    END IF;

    IF v_time_column IS NOT NULL THEN
        SELECT a.atttypid
        INTO v_time_type
        FROM pg_attribute a
        WHERE a.attrelid = v_relid
          AND a.attname = v_time_column
          AND a.attnum > 0
          AND NOT a.attisdropped;

        IF v_time_type IN (
            'date'::regtype,
            'timestamp without time zone'::regtype,
            'timestamp with time zone'::regtype
        ) THEN
            EXECUTE format(
                'SELECT min(%1$I)::timestamptz, max(%1$I)::timestamptz, count(*)::bigint FROM %2$I.%3$I WHERE %1$I IS NOT NULL',
                v_time_column,
                p_schema,
                p_table
            )
            INTO v_min_ts, v_max_ts, v_nonnull_rows;

            IF v_min_ts IS NOT NULL AND v_max_ts IS NOT NULL THEN
                v_span_years := round(extract(epoch FROM (v_max_ts - v_min_ts)) / 31557600.0, 2);
            END IF;
        END IF;
    END IF;

    v_ratio := CASE WHEN v_idx_scan = 0 THEN NULL ELSE round(v_seq_scan::numeric / v_idx_scan::numeric, 2) END;

    v_score := v_score
        + CASE
            WHEN v_total_bytes >= 1500::bigint * 1024 * 1024 * 1024 THEN 45
            WHEN v_total_bytes >= 500::bigint * 1024 * 1024 * 1024 THEN 35
            WHEN v_total_bytes >= 100::bigint * 1024 * 1024 * 1024 THEN 25
            WHEN v_total_bytes >= 20::bigint * 1024 * 1024 * 1024 THEN 15
            WHEN v_total_bytes >= 5::bigint * 1024 * 1024 * 1024 THEN 8
            ELSE 0
          END
        + CASE
            WHEN coalesce(v_span_years, 0) >= 10 THEN 25
            WHEN coalesce(v_span_years, 0) >= 5 THEN 16
            WHEN coalesce(v_span_years, 0) >= 3 THEN 10
            WHEN coalesce(v_span_years, 0) >= 1 THEN 5
            ELSE 0
          END
        + CASE
            WHEN v_write_volume >= 100000000 THEN 15
            WHEN v_write_volume >= 10000000 THEN 10
            WHEN v_write_volume >= 1000000 THEN 5
            ELSE 0
          END
        + CASE
            WHEN v_seq_tup_read >= 100000000 THEN 10
            WHEN v_seq_tup_read >= 10000000 THEN 6
            WHEN v_seq_scan > v_idx_scan AND v_seq_tup_read >= 1000000 THEN 4
            ELSE 0
          END
        + CASE
            WHEN v_time_column IS NOT NULL THEN 7
            ELSE 0
          END;

    v_reco := CASE
        WHEN v_score >= 65 THEN 'REQUIRED_NOW'
        WHEN v_score >= 45 THEN 'STRONGLY_RECOMMENDED'
        WHEN v_score >= 30 THEN 'EVALUATE_WITH_EXPLAIN'
        ELSE 'LOW_PRIORITY'
    END;

    v_grain := CASE
        WHEN v_time_column IS NULL THEN
            'No temporal column selected; evaluate HASH/LIST only when access pattern needs it.'
        WHEN coalesce(v_span_years, 0) >= 10 AND v_total_bytes >= 500::bigint * 1024 * 1024 * 1024 THEN
            'YEARLY parent with MONTHLY partitions for hot recent ' || p_hot_window_months || '-month window.'
        WHEN coalesce(v_span_years, 0) >= 5 THEN
            'MONTHLY partitions (optionally quarterly for cold historical data).'
        WHEN coalesce(v_span_years, 0) >= 1 THEN
            'WEEKLY or MONTHLY partitions based on retention and query windows.'
        ELSE
            'Partitioning mainly for retention/isolation, not pruning benefit.'
    END;

    v_steps := CASE
        WHEN v_reco IN ('REQUIRED_NOW', 'STRONGLY_RECOMMENDED') THEN
            '1) Validate key in top query predicates. 2) Create partitioned shadow table. 3) Backfill in chunks ordered by time key. 4) Create local indexes. 5) Swap tables in controlled release. 6) Add partition maintenance + retention jobs.'
        WHEN v_reco = 'EVALUATE_WITH_EXPLAIN' THEN
            '1) Benchmark top queries with and without partition pruning. 2) Compare against index and schema-only optimization. 3) Partition only when measurable latency/maintenance gains are proven.'
        ELSE
            'No immediate partitioning project. Continue indexing/vacuum tuning and reassess after growth milestones.'
    END;

    v_reason := 'size_gb='
        || to_char(round(v_total_bytes / 1024.0 / 1024.0 / 1024.0, 2), 'FM9999999990.00')
        || '; span_years='
        || coalesce(v_span_years::text, 'n/a')
        || '; write_volume='
        || v_write_volume::text
        || '; seq_scan='
        || v_seq_scan::text
        || '; idx_scan='
        || v_idx_scan::text
        || '; seq_tup_read='
        || v_seq_tup_read::text
        || '; selected_time_column='
        || coalesce(v_time_column, '(none)');

    RETURN QUERY
    SELECT
        p_schema,
        p_table,
        round(v_total_bytes / 1024.0 / 1024.0 / 1024.0, 2),
        v_live_rows,
        v_write_volume,
        v_seq_scan,
        v_idx_scan,
        v_ratio,
        coalesce(v_time_column, '(none)'),
        v_min_ts,
        v_max_ts,
        v_span_years,
        v_score,
        v_reco,
        v_grain,
        v_steps,
        v_reason;
END;
$$;

WITH params AS (
    SELECT
        'partition_lab'::text AS target_schema,
        'fact_events_10y_unpartitioned'::text AS target_table,
        'event_date'::text AS target_time_column,
        6::int AS hot_window_months
)
SELECT a.*
FROM params p
CROSS JOIN LATERAL pg_temp.partition_target_table_advisor(
    p.target_schema,
    p.target_table,
    p.target_time_column,
    p.hot_window_months
) AS a;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture file: /tmp/partition_new_outputs_20260218/06.out.txt
--
-- CREATE FUNCTION
--   schema_name  |          table_name           | total_size_gb | estimated_live_rows | write_volume | seq_scan | idx_scan | seq_to_idx_ratio | selected_time_column |     min_time_value     |     max_time_value     | span_years | partition_readiness_score |    recommendation    |                        suggested_granularity                        |                                                                                                        developer_action_steps                                                                                                         |                                                         decision_rationale                                                          
-- ---------------+-------------------------------+---------------+---------------------+--------------+----------+----------+------------------+----------------------+------------------------+------------------------+------------+---------------------------+----------------------+---------------------------------------------------------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------------------------------------------------
--  partition_lab | fact_events_10y_unpartitioned |          5.00 |             4500006 |      4500000 |        7 |        0 |                  | event_date           | 2016-02-18 00:00:00-05 | 2026-02-18 00:00:00-05 |      10.00 |                        49 | STRONGLY_RECOMMENDED | MONTHLY partitions (optionally quarterly for cold historical data). | 1) Validate key in top query predicates. 2) Create partitioned shadow table. 3) Backfill in chunks ordered by time key. 4) Create local indexes. 5) Swap tables in controlled release. 6) Add partition maintenance + retention jobs. | size_gb=5.00; span_years=10.00; write_volume=4500000; seq_scan=7; idx_scan=0; seq_tup_read=9000000; selected_time_column=event_date
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
