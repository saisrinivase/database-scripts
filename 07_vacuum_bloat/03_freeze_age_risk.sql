/*
PostgreSQL DBA Script: Freeze Age Risk
Purpose: Identify tables approaching anti-wraparound vacuum risk.
Area: Vacuum and Bloat
Usage: Compare results with autovacuum_freeze_max_age settings.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    age(c.relfrozenxid) AS relfrozenxid_age,
    age(t.relfrozenxid) AS toast_relfrozenxid_age,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
LEFT JOIN pg_class t
    ON t.oid = c.reltoastrelid
WHERE c.relkind IN ('r', 'm')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY relfrozenxid_age DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | relfrozenxid_age | toast_relfrozenxid_age | total_size 
-- ------------------+-------------------------+------------------+------------------------+------------
--  public           | pgbench_accounts        |          5333873 |                        | 30 GB
--  public           | pgbench_history         |          5333822 |                        | 270 MB
--  public           | pgbench_tellers         |           171122 |                        | 3712 kB
--  public           | pgbench_branches        |            19214 |                        | 7048 kB
--  dba_metrics      | database_size_snapshots |              159 |                    159 | 16 kB
--  dba_metrics      | table_size_snapshots    |              158 |                    158 | 16 kB
--  dba_metrics      | index_size_snapshots    |              157 |                    157 | 16 kB
--  dba_metrics      | connection_snapshots    |              156 |                    156 | 16 kB
--  dba_metrics      | wal_snapshots           |              155 |                    155 | 16 kB
--  migration_v1_lab | orders_no_pk            |              141 |                    142 | 872 kB
--  migration_v1_lab | parent_accounts         |              136 |                    138 | 792 kB
--  migration_v1_lab | child_transactions      |              135 |                        | 11 MB
--  migration_v1_lab | product_catalog         |              133 |                    134 | 6032 kB
--  migration_v1_lab | sales_orders            |              130 |                    130 | 128 kB
--  migration_v1_lab | stale_stats_table       |              126 |                    128 | 7768 kB
--  migration_v1_lab | dml_bloat_table         |              123 |                    107 | 4248 kB
--  migration_v2_lab | issue_manifest          |              101 |                    101 | 32 kB
--  migration_v2_lab | customer_staging_no_pk  |               98 |                     99 | 5016 kB
--  migration_v2_lab | parent_accounts         |               93 |                     95 | 4096 kB
--  migration_v2_lab | child_events            |               92 |                     94 | 25 MB
--  migration_v2_lab | sales_catalog           |               90 |                     91 | 14 MB
--  migration_v2_lab | quoted_orders           |               86 |                     87 | 496 kB
--  migration_v2_lab | stale_stats_table       |               83 |                     85 | 24 MB
--  migration_v2_lab | bloat_pressure_table    |               80 |                     36 | 14 MB
--  migration_v2_lab | customer_contact_compat |               77 |                     78 | 13 MB
--  migration_v2_lab | order_fact              |               73 |                     74 | 49 MB
--  migration_v2_lab | trigger_audit_demo      |               71 |                     71 | 16 kB
--  migration_v2_lab | partitioned_events_2025 |               61 |                     63 | 5560 kB
--  migration_v2_lab | partitioned_events_2026 |               61 |                     62 | 5104 kB
--  migration_v2_lab | amount_mapping_risk     |               33 |                        | 19 MB
--  migration_v2_lab | mv_daily_order_volume   |               30 |                     30 | 24 kB
-- (31 rows)
-- 
-- SAMPLE_OUTPUT_END
