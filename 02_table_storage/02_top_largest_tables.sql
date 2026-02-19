/*
Purpose: Quickly list the largest tables in the current database.
Area: Table Storage
Usage: Change LIMIT value based on reporting need.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    pg_total_relation_size(c.oid) AS total_bytes,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_pretty,
    s.n_live_tup AS estimated_live_rows,
    s.n_dead_tup AS estimated_dead_rows
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
LEFT JOIN pg_stat_user_tables s
    ON s.relid = c.oid
WHERE c.relkind IN ('r', 'm')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY total_bytes DESC
LIMIT 50;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | total_bytes | total_pretty | estimated_live_rows | estimated_dead_rows 
-- ------------------+-------------------------+-------------+--------------+---------------------+---------------------
--  public           | pgbench_accounts        | 31716564992 | 30 GB        |           200000029 |             4232485
--  public           | pgbench_history         |   282656768 | 270 MB       |             5331130 |                   0
--  migration_v2_lab | order_fact              |    51806208 | 49 MB        |              300000 |                   0
--  migration_v2_lab | child_events            |    25714688 | 25 MB        |              250000 |                   0
--  migration_v2_lab | stale_stats_table       |    25174016 | 24 MB        |              180000 |                   0
--  migration_v2_lab | amount_mapping_risk     |    20119552 | 19 MB        |              120000 |                   0
--  migration_v2_lab | sales_catalog           |    14745600 | 14 MB        |              120000 |                   0
--  migration_v2_lab | bloat_pressure_table    |    14163968 | 14 MB        |               42000 |                   0
--  migration_v2_lab | customer_contact_compat |    13107200 | 13 MB        |               90000 |                   0
--  migration_v1_lab | child_transactions      |    11051008 | 11 MB        |              120000 |                   0
--  migration_v1_lab | stale_stats_table       |     7954432 | 7768 kB      |               60000 |                   0
--  public           | pgbench_branches        |     7217152 | 7048 kB      |                2000 |                  81
--  migration_v1_lab | product_catalog         |     6176768 | 6032 kB      |               50000 |                   0
--  migration_v2_lab | partitioned_events_2025 |     5693440 | 5560 kB      |               52194 |                   0
--  migration_v2_lab | partitioned_events_2026 |     5226496 | 5104 kB      |               47806 |                   0
--  migration_v2_lab | customer_staging_no_pk  |     5136384 | 5016 kB      |               60000 |                   0
--  migration_v1_lab | dml_bloat_table         |     4349952 | 4248 kB      |               12000 |                   0
--  migration_v2_lab | parent_accounts         |     4194304 | 4096 kB      |               50000 |                   0
--  public           | pgbench_tellers         |     3801088 | 3712 kB      |               20000 |                   0
--  migration_v1_lab | orders_no_pk            |      892928 | 872 kB       |               10000 |                   0
--  migration_v1_lab | parent_accounts         |      811008 | 792 kB       |               10000 |                   0
--  migration_v2_lab | quoted_orders           |      507904 | 496 kB       |                5000 |                   0
--  migration_v1_lab | sales_orders            |      131072 | 128 kB       |                1000 |                   0
--  migration_v2_lab | issue_manifest          |       32768 | 32 kB        |                  11 |                   0
--  migration_v2_lab | mv_daily_order_volume   |       24576 | 24 kB        |                   1 |                   0
--  migration_v2_lab | trigger_audit_demo      |       16384 | 16 kB        |                   0 |                   0
--  dba_metrics      | wal_snapshots           |       16384 | 16 kB        |                   1 |                   0
--  dba_metrics      | connection_snapshots    |       16384 | 16 kB        |                   3 |                   0
--  dba_metrics      | index_size_snapshots    |       16384 | 16 kB        |                  21 |                   0
--  dba_metrics      | table_size_snapshots    |       16384 | 16 kB        |                  25 |                   0
--  dba_metrics      | database_size_snapshots |       16384 | 16 kB        |                   7 |                   0
-- (31 rows)
-- 
-- SAMPLE_OUTPUT_END
