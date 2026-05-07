/*
PostgreSQL DBA Script: Relation Storage Parameters
Purpose: Inspect per-table storage settings (fillfactor, autovacuum overrides, etc.).
Area: Table Storage
Usage: Useful when tuning table-level storage behavior.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    c.reloptions AS relation_options
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'm', 'p')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY n.nspname, c.relname;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | relation_options 
-- ------------------+-------------------------+------------------
--  dba_metrics      | connection_snapshots    | 
--  dba_metrics      | database_size_snapshots | 
--  dba_metrics      | index_size_snapshots    | 
--  dba_metrics      | table_size_snapshots    | 
--  dba_metrics      | wal_snapshots           | 
--  migration_v1_lab | child_transactions      | 
--  migration_v1_lab | dml_bloat_table         | 
--  migration_v1_lab | orders_no_pk            | 
--  migration_v1_lab | parent_accounts         | 
--  migration_v1_lab | product_catalog         | 
--  migration_v1_lab | sales_orders            | 
--  migration_v1_lab | stale_stats_table       | 
--  migration_v2_lab | amount_mapping_risk     | 
--  migration_v2_lab | bloat_pressure_table    | 
--  migration_v2_lab | child_events            | 
--  migration_v2_lab | customer_contact_compat | 
--  migration_v2_lab | customer_staging_no_pk  | 
--  migration_v2_lab | issue_manifest          | 
--  migration_v2_lab | mv_daily_order_volume   | 
--  migration_v2_lab | order_fact              | 
--  migration_v2_lab | parent_accounts         | 
--  migration_v2_lab | partitioned_events      | 
--  migration_v2_lab | partitioned_events_2025 | 
--  migration_v2_lab | partitioned_events_2026 | 
--  migration_v2_lab | quoted_orders           | 
--  migration_v2_lab | sales_catalog           | 
--  migration_v2_lab | stale_stats_table       | 
--  migration_v2_lab | trigger_audit_demo      | 
--  public           | pgbench_accounts        | {fillfactor=100}
--  public           | pgbench_branches        | {fillfactor=100}
--  public           | pgbench_history         | 
--  public           | pgbench_tellers         | {fillfactor=100}
-- (32 rows)
-- 
-- SAMPLE_OUTPUT_END
