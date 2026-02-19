/*
Purpose: Inspect per-table storage settings (fillfactor, autovacuum overrides, etc.).
Area: Table Storage
Usage: Useful when tuning table-level storage behavior.
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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    |       table_name        | relation_options 
------------------+-------------------------+------------------
 dba_metrics      | connection_snapshots    | 
 dba_metrics      | database_size_snapshots | 
 dba_metrics      | index_size_snapshots    | 
 dba_metrics      | table_size_snapshots    | 
 dba_metrics      | wal_snapshots           | 
 migration_v1_lab | child_transactions      | 
 migration_v1_lab | dml_bloat_table         | 
 migration_v1_lab | orders_no_pk            | 
 migration_v1_lab | parent_accounts         | 
 migration_v1_lab | product_catalog         | 
 migration_v1_lab | sales_orders            | 
 migration_v1_lab | stale_stats_table       | 
 perf             | addresses               | 
 perf             | app_events              | 
 perf             | audit_log               | 
 perf             | categories              | 
 perf             | documents               | 
 perf             | feature_flags           | 
 perf             | inventory               | 
 perf             | job_runs                | 
 perf             | jobs                    | 
 perf             | notifications           | 
 perf             | order_items             | 
 perf             | orders                  | 
 perf             | payments                | 
 perf             | product_categories      | 
 perf             | products                | 
 perf             | sessions                | 
 perf             | shipments               | 
 perf             | support_tickets         | 
 perf             | tenants                 | 
 perf             | ticket_comments         | 
 perf             | users                   | 
 public           | demo_users              | 
(34 rows)


SAMPLE_OUTPUT_END */
