/*
Purpose: Find tables with potentially excessive index count relative to write activity.
Area: Design Matters
Usage: Over-indexing can slow INSERT/UPDATE/DELETE workloads.
*/
WITH idx_count AS (
    SELECT
        i.indrelid AS relid,
        count(*) AS index_count
    FROM pg_index i
    GROUP BY i.indrelid
)
SELECT
    s.schemaname AS schema_name,
    s.relname AS table_name,
    coalesce(i.index_count, 0) AS index_count,
    (s.n_tup_ins + s.n_tup_upd + s.n_tup_del) AS total_writes,
    pg_size_pretty(pg_total_relation_size(s.relid)) AS total_size
FROM pg_stat_user_tables s
LEFT JOIN idx_count i
    ON i.relid = s.relid
ORDER BY index_count DESC, total_writes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | index_count | total_writes | total_size 
-- ------------------+-------------------------+-------------+--------------+------------
--  migration_v2_lab | order_fact              |           3 |       300000 | 49 MB
--  migration_v2_lab | child_events            |           2 |       250000 | 25 MB
--  migration_v2_lab | sales_catalog           |           2 |       120000 | 14 MB
--  migration_v1_lab | child_transactions      |           2 |       120000 | 11 MB
--  migration_v1_lab | product_catalog         |           2 |        50000 | 6032 kB
--  public           | pgbench_accounts        |           1 |    205332823 | 30 GB
--  public           | pgbench_tellers         |           1 |      5352823 | 3712 kB
--  public           | pgbench_branches        |           1 |      5334823 | 7048 kB
--  migration_v2_lab | amount_mapping_risk     |           1 |       240000 | 19 MB
--  migration_v2_lab | stale_stats_table       |           1 |       180000 | 24 MB
--  migration_v2_lab | customer_contact_compat |           1 |       141429 | 13 MB
--  migration_v2_lab | bloat_pressure_table    |           1 |       138000 | 14 MB
--  migration_v1_lab | stale_stats_table       |           1 |        60000 | 7768 kB
--  migration_v2_lab | customer_staging_no_pk  |           1 |        60000 | 5016 kB
--  migration_v2_lab | partitioned_events_2025 |           1 |        52194 | 5560 kB
--  migration_v2_lab | parent_accounts         |           1 |        50000 | 4096 kB
--  migration_v2_lab | partitioned_events_2026 |           1 |        47806 | 5104 kB
--  migration_v1_lab | dml_bloat_table         |           1 |        38000 | 4248 kB
--  migration_v1_lab | orders_no_pk            |           1 |        10000 | 872 kB
--  migration_v1_lab | parent_accounts         |           1 |        10000 | 792 kB
--  migration_v2_lab | quoted_orders           |           1 |         5000 | 496 kB
--  migration_v1_lab | sales_orders            |           1 |         1000 | 128 kB
--  migration_v2_lab | issue_manifest          |           1 |           11 | 32 kB
--  migration_v2_lab | partitioned_events      |           1 |            0 | 0 bytes
--  migration_v2_lab | trigger_audit_demo      |           1 |            0 | 16 kB
--  public           | pgbench_history         |           0 |      5332823 | 270 MB
--  dba_metrics      | table_size_snapshots    |           0 |           57 | 16 kB
--  dba_metrics      | index_size_snapshots    |           0 |           51 | 16 kB
--  dba_metrics      | database_size_snapshots |           0 |           14 | 16 kB
--  dba_metrics      | connection_snapshots    |           0 |            6 | 16 kB
--  migration_v2_lab | mv_daily_order_volume   |           0 |            2 | 24 kB
--  dba_metrics      | wal_snapshots           |           0 |            2 | 16 kB
-- (32 rows)
-- 
-- SAMPLE_OUTPUT_END
