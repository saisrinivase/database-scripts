/*
Purpose: Rank tables by write volume to target DML optimization and maintenance.
Area: Optimizing Data Modification
Usage: Run before tuning autovacuum, indexing, and partition strategy.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    n_tup_ins,
    n_tup_upd,
    n_tup_del,
    (n_tup_ins + n_tup_upd + n_tup_del) AS total_writes,
    n_live_tup,
    n_dead_tup,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
ORDER BY total_writes DESC
LIMIT 200;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | n_tup_ins | n_tup_upd | n_tup_del | total_writes | n_live_tup | n_dead_tup | total_size 
-- ------------------+-------------------------+-----------+-----------+-----------+--------------+------------+------------+------------
--  public           | pgbench_accounts        | 200000000 |   5332823 |         0 |    205332823 |  200000029 |    4232485 | 30 GB
--  public           | pgbench_tellers         |     20000 |   5332823 |         0 |      5352823 |      20000 |          0 | 3712 kB
--  public           | pgbench_branches        |      2000 |   5332823 |         0 |      5334823 |       2000 |         81 | 7048 kB
--  public           | pgbench_history         |   5332823 |         0 |         0 |      5332823 |    5331130 |          0 | 270 MB
--  migration_v2_lab | order_fact              |    300000 |         0 |         0 |       300000 |     300000 |          0 | 49 MB
--  migration_v2_lab | child_events            |    250000 |         0 |         0 |       250000 |     250000 |          0 | 25 MB
--  migration_v2_lab | amount_mapping_risk     |    120000 |    120000 |         0 |       240000 |     120000 |          0 | 19 MB
--  migration_v2_lab | stale_stats_table       |    180000 |         0 |         0 |       180000 |     180000 |          0 | 24 MB
--  migration_v2_lab | customer_contact_compat |     90000 |     51429 |         0 |       141429 |      90000 |          0 | 13 MB
--  migration_v2_lab | bloat_pressure_table    |     90000 |         0 |     48000 |       138000 |      42000 |          0 | 14 MB
--  migration_v2_lab | sales_catalog           |    120000 |         0 |         0 |       120000 |     120000 |          0 | 14 MB
--  migration_v1_lab | child_transactions      |    120000 |         0 |         0 |       120000 |     120000 |          0 | 11 MB
--  migration_v2_lab | customer_staging_no_pk  |     60000 |         0 |         0 |        60000 |      60000 |          0 | 5016 kB
--  migration_v1_lab | stale_stats_table       |     60000 |         0 |         0 |        60000 |      60000 |          0 | 7768 kB
--  migration_v2_lab | partitioned_events_2025 |     52194 |         0 |         0 |        52194 |      52194 |          0 | 5560 kB
--  migration_v2_lab | parent_accounts         |     50000 |         0 |         0 |        50000 |      50000 |          0 | 4096 kB
--  migration_v1_lab | product_catalog         |     50000 |         0 |         0 |        50000 |      50000 |          0 | 6032 kB
--  migration_v2_lab | partitioned_events_2026 |     47806 |         0 |         0 |        47806 |      47806 |          0 | 5104 kB
--  migration_v1_lab | dml_bloat_table         |     25000 |         0 |     13000 |        38000 |      12000 |          0 | 4248 kB
--  migration_v1_lab | parent_accounts         |     10000 |         0 |         0 |        10000 |      10000 |          0 | 792 kB
--  migration_v1_lab | orders_no_pk            |     10000 |         0 |         0 |        10000 |      10000 |          0 | 872 kB
--  migration_v2_lab | quoted_orders           |      5000 |         0 |         0 |         5000 |       5000 |          0 | 496 kB
--  migration_v1_lab | sales_orders            |      1000 |         0 |         0 |         1000 |       1000 |          0 | 128 kB
--  dba_metrics      | table_size_snapshots    |        57 |         0 |         0 |           57 |         57 |          0 | 16 kB
--  dba_metrics      | index_size_snapshots    |        51 |         0 |         0 |           51 |         51 |          0 | 16 kB
--  dba_metrics      | database_size_snapshots |        14 |         0 |         0 |           14 |         14 |          0 | 16 kB
--  migration_v2_lab | issue_manifest          |        11 |         0 |         0 |           11 |         11 |          0 | 32 kB
--  dba_metrics      | connection_snapshots    |         6 |         0 |         0 |            6 |          6 |          0 | 16 kB
--  dba_metrics      | wal_snapshots           |         2 |         0 |         0 |            2 |          2 |          0 | 16 kB
--  migration_v2_lab | mv_daily_order_volume   |         2 |         0 |         0 |            2 |          1 |          0 | 24 kB
--  migration_v2_lab | trigger_audit_demo      |         0 |         0 |         0 |            0 |          0 |          0 | 16 kB
--  migration_v2_lab | partitioned_events      |         0 |         0 |         0 |            0 |          0 |          0 | 0 bytes
-- (32 rows)
-- 
-- SAMPLE_OUTPUT_END
