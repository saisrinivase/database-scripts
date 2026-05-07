/*
PostgreSQL DBA Script: Tables With Toast
Purpose: List tables that own TOAST tables and their TOAST size.
Area: TOAST / LOB / BLOB
Usage: TOAST size helps explain hidden storage growth for wide rows.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    t.relname AS toast_table_name,
    pg_total_relation_size(t.oid) AS toast_total_bytes,
    pg_size_pretty(pg_total_relation_size(t.oid)) AS toast_total_pretty
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
JOIN pg_class t
    ON t.oid = c.reltoastrelid
WHERE c.relkind IN ('r', 'm')
  AND c.reltoastrelid <> 0
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY toast_total_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | toast_table_name | toast_total_bytes | toast_total_pretty 
-- ------------------+-------------------------+------------------+-------------------+--------------------
--  migration_v1_lab | orders_no_pk            | pg_toast_27382   |              8192 | 8192 bytes
--  migration_v1_lab | parent_accounts         | pg_toast_27392   |              8192 | 8192 bytes
--  migration_v1_lab | product_catalog         | pg_toast_27418   |              8192 | 8192 bytes
--  migration_v2_lab | issue_manifest          | pg_toast_27479   |              8192 | 8192 bytes
--  migration_v1_lab | stale_stats_table       | pg_toast_27443   |              8192 | 8192 bytes
--  migration_v1_lab | sales_orders            | pg_toast_27434   |              8192 | 8192 bytes
--  migration_v1_lab | dml_bloat_table         | pg_toast_27453   |              8192 | 8192 bytes
--  migration_v2_lab | customer_staging_no_pk  | pg_toast_27491   |              8192 | 8192 bytes
--  dba_metrics      | database_size_snapshots | pg_toast_27311   |              8192 | 8192 bytes
--  dba_metrics      | table_size_snapshots    | pg_toast_27320   |              8192 | 8192 bytes
--  dba_metrics      | index_size_snapshots    | pg_toast_27330   |              8192 | 8192 bytes
--  dba_metrics      | connection_snapshots    | pg_toast_27341   |              8192 | 8192 bytes
--  dba_metrics      | wal_snapshots           | pg_toast_27349   |              8192 | 8192 bytes
--  migration_v2_lab | parent_accounts         | pg_toast_27502   |              8192 | 8192 bytes
--  migration_v2_lab | child_events            | pg_toast_27514   |              8192 | 8192 bytes
--  migration_v2_lab | sales_catalog           | pg_toast_27533   |              8192 | 8192 bytes
--  migration_v2_lab | bloat_pressure_table    | pg_toast_27572   |              8192 | 8192 bytes
--  migration_v2_lab | quoted_orders           | pg_toast_27549   |              8192 | 8192 bytes
--  migration_v2_lab | stale_stats_table       | pg_toast_27560   |              8192 | 8192 bytes
--  migration_v2_lab | customer_contact_compat | pg_toast_27584   |              8192 | 8192 bytes
--  migration_v2_lab | trigger_audit_demo      | pg_toast_27626   |              8192 | 8192 bytes
--  migration_v2_lab | partitioned_events_2025 | pg_toast_27665   |              8192 | 8192 bytes
--  migration_v2_lab | order_fact              | pg_toast_27603   |              8192 | 8192 bytes
--  migration_v2_lab | partitioned_events_2026 | pg_toast_27675   |              8192 | 8192 bytes
--  migration_v2_lab | mv_daily_order_volume   | pg_toast_27645   |              8192 | 8192 bytes
-- (25 rows)
-- 
-- SAMPLE_OUTPUT_END

