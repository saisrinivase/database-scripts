/*
Purpose: Show per-table storage split (heap, index, TOAST, total).
Area: Table Storage
Usage: Run in target database; adjust WHERE clause for specific schemas.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    pg_relation_size(c.oid) AS heap_bytes,
    pg_indexes_size(c.oid) AS index_bytes,
    CASE WHEN c.reltoastrelid = 0 THEN 0 ELSE pg_total_relation_size(c.reltoastrelid) END AS toast_bytes,
    pg_total_relation_size(c.oid) AS total_bytes,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_pretty
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'm')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY total_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | heap_bytes  | index_bytes | toast_bytes | total_bytes | total_pretty 
-- ------------------+-------------------------+-------------+-------------+-------------+-------------+--------------
--  public           | pgbench_accounts        | 27216674816 |  4492353536 |           0 | 31716564992 | 30 GB
--  public           | pgbench_history         |   282558464 |           0 |           0 |   282656768 | 270 MB
--  migration_v2_lab | order_fact              |    27934720 |    23830528 |        8192 |    51806208 | 49 MB
--  migration_v2_lab | child_events            |    17072128 |     8601600 |        8192 |    25714688 | 25 MB
--  migration_v2_lab | stale_stats_table       |    21069824 |     4063232 |        8192 |    25174016 | 24 MB
--  migration_v2_lab | amount_mapping_risk     |    14663680 |     5423104 |           0 |    20119552 | 19 MB
--  migration_v2_lab | sales_catalog           |     8192000 |     6512640 |        8192 |    14745600 | 14 MB
--  migration_v2_lab | bloat_pressure_table    |    12091392 |     2031616 |        8192 |    14163968 | 14 MB
--  migration_v2_lab | customer_contact_compat |     8994816 |     4071424 |        8192 |    13107200 | 13 MB
--  migration_v1_lab | child_transactions      |     7233536 |     3784704 |           0 |    11051008 | 11 MB
--  migration_v1_lab | stale_stats_table       |     6553600 |     1359872 |        8192 |     7954432 | 7768 kB
--  public           | pgbench_branches        |     7028736 |      155648 |           0 |     7217152 | 7048 kB
--  migration_v1_lab | product_catalog         |     3416064 |     2719744 |        8192 |     6176768 | 6032 kB
--  migration_v2_lab | partitioned_events_2025 |     3997696 |     1654784 |        8192 |     5693440 | 5560 kB
--  migration_v2_lab | partitioned_events_2026 |     3661824 |     1523712 |        8192 |     5226496 | 5104 kB
--  migration_v2_lab | customer_staging_no_pk  |     3735552 |     1359872 |        8192 |     5136384 | 5016 kB
--  migration_v1_lab | dml_bloat_table         |     3727360 |      581632 |        8192 |     4349952 | 4248 kB
--  migration_v2_lab | parent_accounts         |     3014656 |     1138688 |        8192 |     4194304 | 4096 kB
--  public           | pgbench_tellers         |     2859008 |      909312 |           0 |     3801088 | 3712 kB
--  migration_v1_lab | orders_no_pk            |      606208 |      245760 |        8192 |      892928 | 872 kB
--  migration_v1_lab | parent_accounts         |      524288 |      245760 |        8192 |      811008 | 792 kB
--  migration_v2_lab | quoted_orders           |      335872 |      131072 |        8192 |      507904 | 496 kB
--  migration_v1_lab | sales_orders            |       57344 |       40960 |        8192 |      131072 | 128 kB
--  migration_v2_lab | issue_manifest          |        8192 |       16384 |        8192 |       32768 | 32 kB
--  migration_v2_lab | mv_daily_order_volume   |        8192 |           0 |        8192 |       24576 | 24 kB
--  migration_v2_lab | trigger_audit_demo      |           0 |        8192 |        8192 |       16384 | 16 kB
--  dba_metrics      | wal_snapshots           |        8192 |           0 |        8192 |       16384 | 16 kB
--  dba_metrics      | connection_snapshots    |        8192 |           0 |        8192 |       16384 | 16 kB
--  dba_metrics      | index_size_snapshots    |        8192 |           0 |        8192 |       16384 | 16 kB
--  dba_metrics      | table_size_snapshots    |        8192 |           0 |        8192 |       16384 | 16 kB
--  dba_metrics      | database_size_snapshots |        8192 |           0 |        8192 |       16384 | 16 kB
-- (31 rows)
-- 
-- SAMPLE_OUTPUT_END

