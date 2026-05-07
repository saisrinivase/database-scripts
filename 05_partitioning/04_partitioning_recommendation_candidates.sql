/*
PostgreSQL DBA Script: Partitioning Recommendation Candidates
Purpose: Heuristically flag large, high-write tables as partitioning candidates.
Area: Partitioning
Usage: Adjust thresholds to match your workload profile.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH base AS (
    SELECT
        s.relid,
        s.schemaname AS schema_name,
        s.relname AS table_name,
        pg_total_relation_size(s.relid) AS total_bytes,
        s.n_live_tup AS estimated_live_rows,
        (s.n_tup_ins + s.n_tup_upd + s.n_tup_del) AS write_volume,
        c.relispartition
    FROM pg_stat_user_tables s
    JOIN pg_class c
        ON c.oid = s.relid
)
SELECT
    schema_name,
    table_name,
    total_bytes,
    pg_size_pretty(total_bytes) AS total_pretty,
    estimated_live_rows,
    write_volume,
    CASE
        WHEN total_bytes >= 50::bigint * 1024 * 1024 * 1024 AND write_volume >= 5000000
            THEN 'Strong candidate'
        WHEN total_bytes >= 20::bigint * 1024 * 1024 * 1024 AND write_volume >= 1000000
            THEN 'Candidate'
        WHEN total_bytes >= 10::bigint * 1024 * 1024 * 1024
            THEN 'Size-only candidate'
        ELSE 'Low priority'
    END AS recommendation
FROM base
WHERE NOT relispartition
ORDER BY total_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | total_bytes | total_pretty | estimated_live_rows | write_volume | recommendation 
-- ------------------+-------------------------+-------------+--------------+---------------------+--------------+----------------
--  public           | pgbench_accounts        | 31716564992 | 30 GB        |           200000029 |    205332823 | Candidate
--  public           | pgbench_history         |   282656768 | 270 MB       |             5331130 |      5332823 | Low priority
--  migration_v2_lab | order_fact              |    51806208 | 49 MB        |              300000 |       300000 | Low priority
--  migration_v2_lab | child_events            |    25714688 | 25 MB        |              250000 |       250000 | Low priority
--  migration_v2_lab | stale_stats_table       |    25174016 | 24 MB        |              180000 |       180000 | Low priority
--  migration_v2_lab | amount_mapping_risk     |    20119552 | 19 MB        |              120000 |       240000 | Low priority
--  migration_v2_lab | sales_catalog           |    14745600 | 14 MB        |              120000 |       120000 | Low priority
--  migration_v2_lab | bloat_pressure_table    |    14163968 | 14 MB        |               42000 |       138000 | Low priority
--  migration_v2_lab | customer_contact_compat |    13107200 | 13 MB        |               90000 |       141429 | Low priority
--  migration_v1_lab | child_transactions      |    11051008 | 11 MB        |              120000 |       120000 | Low priority
--  migration_v1_lab | stale_stats_table       |     7954432 | 7768 kB      |               60000 |        60000 | Low priority
--  public           | pgbench_branches        |     7217152 | 7048 kB      |                2000 |      5334823 | Low priority
--  migration_v1_lab | product_catalog         |     6176768 | 6032 kB      |               50000 |        50000 | Low priority
--  migration_v2_lab | customer_staging_no_pk  |     5136384 | 5016 kB      |               60000 |        60000 | Low priority
--  migration_v1_lab | dml_bloat_table         |     4349952 | 4248 kB      |               12000 |        38000 | Low priority
--  migration_v2_lab | parent_accounts         |     4194304 | 4096 kB      |               50000 |        50000 | Low priority
--  public           | pgbench_tellers         |     3801088 | 3712 kB      |               20000 |      5352823 | Low priority
--  migration_v1_lab | orders_no_pk            |      892928 | 872 kB       |               10000 |        10000 | Low priority
--  migration_v1_lab | parent_accounts         |      811008 | 792 kB       |               10000 |        10000 | Low priority
--  migration_v2_lab | quoted_orders           |      507904 | 496 kB       |                5000 |         5000 | Low priority
--  migration_v1_lab | sales_orders            |      131072 | 128 kB       |                1000 |         1000 | Low priority
--  migration_v2_lab | issue_manifest          |       32768 | 32 kB        |                  11 |           11 | Low priority
--  migration_v2_lab | mv_daily_order_volume   |       24576 | 24 kB        |                   1 |            2 | Low priority
--  migration_v2_lab | trigger_audit_demo      |       16384 | 16 kB        |                   0 |            0 | Low priority
--  dba_metrics      | database_size_snapshots |       16384 | 16 kB        |                   7 |            7 | Low priority
--  dba_metrics      | connection_snapshots    |       16384 | 16 kB        |                   3 |            3 | Low priority
--  dba_metrics      | wal_snapshots           |       16384 | 16 kB        |                   1 |            1 | Low priority
--  dba_metrics      | index_size_snapshots    |       16384 | 16 kB        |                  21 |           21 | Low priority
--  dba_metrics      | table_size_snapshots    |       16384 | 16 kB        |                  25 |           25 | Low priority
--  migration_v2_lab | partitioned_events      |           0 | 0 bytes      |                   0 |            0 | Low priority
-- (30 rows)
-- 
-- SAMPLE_OUTPUT_END
