/*
PostgreSQL DBA Script: Wide Tables Profile
Purpose: Profile table width and column counts to detect design patterns that can degrade performance.
Area: Design Matters
Usage: Use with normalization and access pattern review.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH col AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS table_name,
        count(a.attnum) FILTER (WHERE a.attnum > 0 AND NOT a.attisdropped) AS column_count
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    JOIN pg_attribute a ON a.attrelid = c.oid
    WHERE c.relkind = 'r'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
    GROUP BY n.nspname, c.relname, c.oid
)
SELECT
    c.schema_name,
    c.table_name,
    c.column_count,
    s.n_live_tup AS estimated_live_rows,
    pg_size_pretty(pg_total_relation_size(s.relid)) AS total_size
FROM col c
JOIN pg_stat_user_tables s
    ON s.schemaname = c.schema_name
   AND s.relname = c.table_name
ORDER BY c.column_count DESC, pg_total_relation_size(s.relid) DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | column_count | estimated_live_rows | total_size 
-- ------------------+-------------------------+--------------+---------------------+------------
--  public           | pgbench_history         |            6 |             5331130 | 270 MB
--  migration_v2_lab | order_fact              |            6 |              300000 | 49 MB
--  dba_metrics      | index_size_snapshots    |            6 |                  51 | 16 kB
--  dba_metrics      | table_size_snapshots    |            6 |                  57 | 16 kB
--  dba_metrics      | connection_snapshots    |            6 |                   6 | 16 kB
--  migration_v2_lab | child_events            |            5 |              250000 | 25 MB
--  migration_v2_lab | amount_mapping_risk     |            5 |              120000 | 19 MB
--  migration_v2_lab | sales_catalog           |            5 |              120000 | 14 MB
--  migration_v1_lab | product_catalog         |            5 |               50000 | 6032 kB
--  dba_metrics      | wal_snapshots           |            5 |                   2 | 16 kB
--  public           | pgbench_accounts        |            4 |           200000029 | 30 GB
--  migration_v2_lab | customer_contact_compat |            4 |               90000 | 13 MB
--  migration_v1_lab | child_transactions      |            4 |              120000 | 11 MB
--  migration_v2_lab | customer_staging_no_pk  |            4 |               60000 | 5016 kB
--  public           | pgbench_tellers         |            4 |               20000 | 3712 kB
--  migration_v2_lab | issue_manifest          |            4 |                  11 | 32 kB
--  migration_v2_lab | stale_stats_table       |            3 |              180000 | 24 MB
--  migration_v2_lab | bloat_pressure_table    |            3 |               42000 | 14 MB
--  public           | pgbench_branches        |            3 |                2000 | 7048 kB
--  migration_v2_lab | partitioned_events_2025 |            3 |               52194 | 5560 kB
--  migration_v2_lab | partitioned_events_2026 |            3 |               47806 | 5104 kB
--  migration_v2_lab | parent_accounts         |            3 |               50000 | 4096 kB
--  migration_v1_lab | orders_no_pk            |            3 |               10000 | 872 kB
--  migration_v2_lab | quoted_orders           |            3 |                5000 | 496 kB
--  migration_v2_lab | trigger_audit_demo      |            3 |                   0 | 16 kB
--  dba_metrics      | database_size_snapshots |            3 |                  14 | 16 kB
--  migration_v1_lab | stale_stats_table       |            2 |               60000 | 7768 kB
--  migration_v1_lab | dml_bloat_table         |            2 |               12000 | 4248 kB
--  migration_v1_lab | parent_accounts         |            2 |               10000 | 792 kB
--  migration_v1_lab | sales_orders            |            2 |                1000 | 128 kB
-- (30 rows)
-- 
-- SAMPLE_OUTPUT_END
