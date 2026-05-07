/*
PostgreSQL DBA Script: Fsm Vm Toast Size Breakdown
Purpose: Break down main/FSM/VM/TOAST forks to inspect internal storage overhead.
Area: Internals Deep Dive
Usage: Helps explain relation size composition beyond heap/index totals.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    pg_relation_size(c.oid, 'main') AS main_bytes,
    pg_relation_size(c.oid, 'fsm') AS fsm_bytes,
    pg_relation_size(c.oid, 'vm') AS vm_bytes,
    CASE WHEN c.reltoastrelid = 0 THEN 0 ELSE pg_total_relation_size(c.reltoastrelid) END AS toast_total_bytes,
    pg_total_relation_size(c.oid) AS table_total_bytes,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS table_total_pretty
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'm')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY table_total_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | main_bytes  | fsm_bytes | vm_bytes | toast_total_bytes | table_total_bytes | table_total_pretty 
-- ------------------+-------------------------+-------------+-----------+----------+-------------------+-------------------+--------------------
--  public           | pgbench_accounts        | 27216674816 |   6709248 |   827392 |                 0 |       31716564992 | 30 GB
--  public           | pgbench_history         |   282558464 |     90112 |     8192 |                 0 |         282656768 | 270 MB
--  migration_v2_lab | order_fact              |    27934720 |     24576 |     8192 |              8192 |          51806208 | 49 MB
--  migration_v2_lab | child_events            |    17072128 |     24576 |     8192 |              8192 |          25714688 | 25 MB
--  migration_v2_lab | stale_stats_table       |    21069824 |     24576 |     8192 |              8192 |          25174016 | 24 MB
--  migration_v2_lab | amount_mapping_risk     |    14663680 |     24576 |     8192 |                 0 |          20119552 | 19 MB
--  migration_v2_lab | sales_catalog           |     8192000 |     24576 |     8192 |              8192 |          14745600 | 14 MB
--  migration_v2_lab | bloat_pressure_table    |    12091392 |     24576 |     8192 |              8192 |          14163968 | 14 MB
--  migration_v2_lab | customer_contact_compat |     8994816 |     24576 |     8192 |              8192 |          13107200 | 13 MB
--  migration_v1_lab | child_transactions      |     7233536 |     24576 |     8192 |                 0 |          11051008 | 11 MB
--  migration_v1_lab | stale_stats_table       |     6553600 |     24576 |     8192 |              8192 |           7954432 | 7768 kB
--  public           | pgbench_branches        |     7028736 |     24576 |     8192 |                 0 |           7217152 | 7048 kB
--  migration_v1_lab | product_catalog         |     3416064 |     24576 |     8192 |              8192 |           6176768 | 6032 kB
--  migration_v2_lab | partitioned_events_2025 |     3997696 |     24576 |     8192 |              8192 |           5693440 | 5560 kB
--  migration_v2_lab | partitioned_events_2026 |     3661824 |     24576 |     8192 |              8192 |           5226496 | 5104 kB
--  migration_v2_lab | customer_staging_no_pk  |     3735552 |     24576 |     8192 |              8192 |           5136384 | 5016 kB
--  migration_v1_lab | dml_bloat_table         |     3727360 |     24576 |     8192 |              8192 |           4349952 | 4248 kB
--  migration_v2_lab | parent_accounts         |     3014656 |     24576 |     8192 |              8192 |           4194304 | 4096 kB
--  public           | pgbench_tellers         |     2859008 |     24576 |     8192 |                 0 |           3801088 | 3712 kB
--  migration_v1_lab | orders_no_pk            |      606208 |     24576 |     8192 |              8192 |            892928 | 872 kB
--  migration_v1_lab | parent_accounts         |      524288 |     24576 |     8192 |              8192 |            811008 | 792 kB
--  migration_v2_lab | quoted_orders           |      335872 |     24576 |     8192 |              8192 |            507904 | 496 kB
--  migration_v1_lab | sales_orders            |       57344 |     24576 |        0 |              8192 |            131072 | 128 kB
--  migration_v2_lab | issue_manifest          |        8192 |         0 |        0 |              8192 |             32768 | 32 kB
--  migration_v2_lab | mv_daily_order_volume   |        8192 |         0 |     8192 |              8192 |             24576 | 24 kB
--  migration_v2_lab | trigger_audit_demo      |           0 |         0 |        0 |              8192 |             16384 | 16 kB
--  dba_metrics      | wal_snapshots           |        8192 |         0 |        0 |              8192 |             16384 | 16 kB
--  dba_metrics      | connection_snapshots    |        8192 |         0 |        0 |              8192 |             16384 | 16 kB
--  dba_metrics      | index_size_snapshots    |        8192 |         0 |        0 |              8192 |             16384 | 16 kB
--  dba_metrics      | table_size_snapshots    |        8192 |         0 |        0 |              8192 |             16384 | 16 kB
--  dba_metrics      | database_size_snapshots |        8192 |         0 |        0 |              8192 |             16384 | 16 kB
-- (31 rows)
-- 
-- SAMPLE_OUTPUT_END
