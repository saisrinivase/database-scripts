/*
PostgreSQL DBA Script: Table Growth Baseline Snapshot
Purpose: Capture current table size and row estimate as a growth baseline snapshot.
Area: Table Storage
Usage: Export results periodically and compare snapshots externally.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    now() AS captured_at,
    s.schemaname AS schema_name,
    s.relname AS table_name,
    s.n_live_tup AS estimated_live_rows,
    s.n_dead_tup AS estimated_dead_rows,
    pg_total_relation_size(s.relid) AS total_bytes,
    pg_size_pretty(pg_total_relation_size(s.relid)) AS total_pretty
FROM pg_stat_user_tables s
ORDER BY total_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--           captured_at          |   schema_name    |       table_name        | estimated_live_rows | estimated_dead_rows | total_bytes | total_pretty 
-- -------------------------------+------------------+-------------------------+---------------------+---------------------+-------------+--------------
--  2026-02-18 19:43:31.089313-05 | public           | pgbench_accounts        |           200000029 |             4232485 | 31716564992 | 30 GB
--  2026-02-18 19:43:31.089313-05 | public           | pgbench_history         |             5331130 |                   0 |   282656768 | 270 MB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | order_fact              |              300000 |                   0 |    51806208 | 49 MB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | child_events            |              250000 |                   0 |    25714688 | 25 MB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | stale_stats_table       |              180000 |                   0 |    25174016 | 24 MB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | amount_mapping_risk     |              120000 |                   0 |    20119552 | 19 MB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | sales_catalog           |              120000 |                   0 |    14745600 | 14 MB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | bloat_pressure_table    |               42000 |                   0 |    14163968 | 14 MB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | customer_contact_compat |               90000 |                   0 |    13107200 | 13 MB
--  2026-02-18 19:43:31.089313-05 | migration_v1_lab | child_transactions      |              120000 |                   0 |    11051008 | 11 MB
--  2026-02-18 19:43:31.089313-05 | migration_v1_lab | stale_stats_table       |               60000 |                   0 |     7954432 | 7768 kB
--  2026-02-18 19:43:31.089313-05 | public           | pgbench_branches        |                2000 |                  81 |     7217152 | 7048 kB
--  2026-02-18 19:43:31.089313-05 | migration_v1_lab | product_catalog         |               50000 |                   0 |     6176768 | 6032 kB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | partitioned_events_2025 |               52194 |                   0 |     5693440 | 5560 kB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | partitioned_events_2026 |               47806 |                   0 |     5226496 | 5104 kB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | customer_staging_no_pk  |               60000 |                   0 |     5136384 | 5016 kB
--  2026-02-18 19:43:31.089313-05 | migration_v1_lab | dml_bloat_table         |               12000 |                   0 |     4349952 | 4248 kB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | parent_accounts         |               50000 |                   0 |     4194304 | 4096 kB
--  2026-02-18 19:43:31.089313-05 | public           | pgbench_tellers         |               20000 |                   0 |     3801088 | 3712 kB
--  2026-02-18 19:43:31.089313-05 | migration_v1_lab | orders_no_pk            |               10000 |                   0 |      892928 | 872 kB
--  2026-02-18 19:43:31.089313-05 | migration_v1_lab | parent_accounts         |               10000 |                   0 |      811008 | 792 kB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | quoted_orders           |                5000 |                   0 |      507904 | 496 kB
--  2026-02-18 19:43:31.089313-05 | migration_v1_lab | sales_orders            |                1000 |                   0 |      131072 | 128 kB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | issue_manifest          |                  11 |                   0 |       32768 | 32 kB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | mv_daily_order_volume   |                   1 |                   0 |       24576 | 24 kB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | trigger_audit_demo      |                   0 |                   0 |       16384 | 16 kB
--  2026-02-18 19:43:31.089313-05 | dba_metrics      | index_size_snapshots    |                  21 |                   0 |       16384 | 16 kB
--  2026-02-18 19:43:31.089313-05 | dba_metrics      | wal_snapshots           |                   1 |                   0 |       16384 | 16 kB
--  2026-02-18 19:43:31.089313-05 | dba_metrics      | database_size_snapshots |                   7 |                   0 |       16384 | 16 kB
--  2026-02-18 19:43:31.089313-05 | dba_metrics      | connection_snapshots    |                   3 |                   0 |       16384 | 16 kB
--  2026-02-18 19:43:31.089313-05 | dba_metrics      | table_size_snapshots    |                  25 |                   0 |       16384 | 16 kB
--  2026-02-18 19:43:31.089313-05 | migration_v2_lab | partitioned_events      |                   0 |                   0 |           0 | 0 bytes
-- (32 rows)
-- 
-- SAMPLE_OUTPUT_END
