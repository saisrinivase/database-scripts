/*
Purpose: Find tables where TOAST occupies a large share of total table size.
Area: TOAST / LOB / BLOB
Usage: Useful for column-level compression/archive strategy reviews.
*/
WITH toast_stats AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS table_name,
        pg_total_relation_size(c.oid) AS table_total_bytes,
        CASE WHEN c.reltoastrelid = 0 THEN 0 ELSE pg_total_relation_size(c.reltoastrelid) END AS toast_bytes
    FROM pg_class c
    JOIN pg_namespace n
        ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r', 'm')
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
)
SELECT
    schema_name,
    table_name,
    table_total_bytes,
    pg_size_pretty(table_total_bytes) AS table_total_pretty,
    toast_bytes,
    pg_size_pretty(toast_bytes) AS toast_pretty,
    round(100.0 * toast_bytes / NULLIF(table_total_bytes, 0), 2) AS toast_pct
FROM toast_stats
WHERE table_total_bytes > 0
ORDER BY toast_pct DESC, toast_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | table_total_bytes | table_total_pretty | toast_bytes | toast_pretty | toast_pct 
-- ------------------+-------------------------+-------------------+--------------------+-------------+--------------+-----------
--  dba_metrics      | database_size_snapshots |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
--  migration_v2_lab | trigger_audit_demo      |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
--  dba_metrics      | wal_snapshots           |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
--  dba_metrics      | connection_snapshots    |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
--  dba_metrics      | index_size_snapshots    |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
--  dba_metrics      | table_size_snapshots    |             16384 | 16 kB              |        8192 | 8192 bytes   |     50.00
--  migration_v2_lab | mv_daily_order_volume   |             24576 | 24 kB              |        8192 | 8192 bytes   |     33.33
--  migration_v2_lab | issue_manifest          |             32768 | 32 kB              |        8192 | 8192 bytes   |     25.00
--  migration_v1_lab | sales_orders            |            131072 | 128 kB             |        8192 | 8192 bytes   |      6.25
--  migration_v2_lab | quoted_orders           |            507904 | 496 kB             |        8192 | 8192 bytes   |      1.61
--  migration_v1_lab | parent_accounts         |            811008 | 792 kB             |        8192 | 8192 bytes   |      1.01
--  migration_v1_lab | orders_no_pk            |            892928 | 872 kB             |        8192 | 8192 bytes   |      0.92
--  migration_v2_lab | parent_accounts         |           4194304 | 4096 kB            |        8192 | 8192 bytes   |      0.20
--  migration_v1_lab | dml_bloat_table         |           4349952 | 4248 kB            |        8192 | 8192 bytes   |      0.19
--  migration_v2_lab | customer_staging_no_pk  |           5136384 | 5016 kB            |        8192 | 8192 bytes   |      0.16
--  migration_v2_lab | partitioned_events_2026 |           5226496 | 5104 kB            |        8192 | 8192 bytes   |      0.16
--  migration_v2_lab | partitioned_events_2025 |           5693440 | 5560 kB            |        8192 | 8192 bytes   |      0.14
--  migration_v1_lab | product_catalog         |           6176768 | 6032 kB            |        8192 | 8192 bytes   |      0.13
--  migration_v1_lab | stale_stats_table       |           7954432 | 7768 kB            |        8192 | 8192 bytes   |      0.10
--  migration_v2_lab | customer_contact_compat |          13107200 | 13 MB              |        8192 | 8192 bytes   |      0.06
--  migration_v2_lab | sales_catalog           |          14745600 | 14 MB              |        8192 | 8192 bytes   |      0.06
--  migration_v2_lab | bloat_pressure_table    |          14163968 | 14 MB              |        8192 | 8192 bytes   |      0.06
--  migration_v2_lab | child_events            |          25714688 | 25 MB              |        8192 | 8192 bytes   |      0.03
--  migration_v2_lab | stale_stats_table       |          25174016 | 24 MB              |        8192 | 8192 bytes   |      0.03
--  migration_v2_lab | order_fact              |          51806208 | 49 MB              |        8192 | 8192 bytes   |      0.02
--  public           | pgbench_branches        |           7217152 | 7048 kB            |           0 | 0 bytes      |      0.00
--  migration_v2_lab | amount_mapping_risk     |          20119552 | 19 MB              |           0 | 0 bytes      |      0.00
--  public           | pgbench_tellers         |           3801088 | 3712 kB            |           0 | 0 bytes      |      0.00
--  migration_v1_lab | child_transactions      |          11051008 | 11 MB              |           0 | 0 bytes      |      0.00
--  public           | pgbench_accounts        |       31716564992 | 30 GB              |           0 | 0 bytes      |      0.00
--  public           | pgbench_history         |         282656768 | 270 MB             |           0 | 0 bytes      |      0.00
-- (31 rows)
-- 
-- SAMPLE_OUTPUT_END
