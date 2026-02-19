/*
Purpose: Highlight tables dominated by sequential scans (possible index or query design issue).
Area: Planner and Statistics
Usage: Validate with query plans before adding indexes.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    seq_scan,
    idx_scan,
    n_live_tup,
    CASE
        WHEN seq_scan + idx_scan = 0 THEN NULL
        ELSE round(100.0 * seq_scan / (seq_scan + idx_scan), 2)
    END AS seq_scan_pct,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
ORDER BY seq_scan DESC, seq_scan_pct DESC NULLS LAST;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | seq_scan | idx_scan | n_live_tup | seq_scan_pct | total_size 
-- ------------------+-------------------------+----------+----------+------------+--------------+------------
--  migration_v2_lab | order_fact              |       11 |        0 |     300000 |       100.00 | 49 MB
--  migration_v2_lab | amount_mapping_risk     |        4 |        0 |     120000 |       100.00 | 19 MB
--  migration_v2_lab | customer_contact_compat |        4 |        0 |      90000 |       100.00 | 13 MB
--  migration_v1_lab | product_catalog         |        3 |        0 |      50000 |       100.00 | 6032 kB
--  migration_v2_lab | sales_catalog           |        3 |        0 |     120000 |       100.00 | 14 MB
--  migration_v2_lab | child_events            |        3 |        0 |     250000 |       100.00 | 25 MB
--  public           | pgbench_branches        |        3 |  5332823 |       2000 |         0.00 | 7048 kB
--  migration_v1_lab | child_transactions      |        2 |        0 |     120000 |       100.00 | 11 MB
--  public           | pgbench_accounts        |        2 | 10665646 |  200000029 |         0.00 | 30 GB
--  migration_v2_lab | trigger_audit_demo      |        1 |        0 |          0 |       100.00 | 16 kB
--  migration_v2_lab | customer_staging_no_pk  |        1 |        0 |      60000 |       100.00 | 5016 kB
--  migration_v2_lab | issue_manifest          |        1 |        0 |         11 |       100.00 | 32 kB
--  migration_v1_lab | orders_no_pk            |        1 |        0 |      10000 |       100.00 | 872 kB
--  migration_v2_lab | stale_stats_table       |        1 |        0 |     180000 |       100.00 | 24 MB
--  migration_v1_lab | stale_stats_table       |        1 |        0 |      60000 |       100.00 | 7768 kB
--  migration_v1_lab | sales_orders            |        1 |        0 |       1000 |       100.00 | 128 kB
--  migration_v2_lab | partitioned_events_2025 |        1 |        0 |      52194 |       100.00 | 5560 kB
--  migration_v2_lab | quoted_orders           |        1 |        0 |       5000 |       100.00 | 496 kB
--  migration_v2_lab | partitioned_events_2026 |        1 |        0 |      47806 |       100.00 | 5104 kB
--  migration_v2_lab | bloat_pressure_table    |        1 |        1 |      42000 |        50.00 | 14 MB
--  migration_v1_lab | dml_bloat_table         |        1 |        1 |      12000 |        50.00 | 4248 kB
--  public           | pgbench_tellers         |        1 |  5332823 |      20000 |         0.00 | 3712 kB
--  migration_v1_lab | parent_accounts         |        1 |   120000 |      10000 |         0.00 | 792 kB
--  migration_v2_lab | parent_accounts         |        1 |   250000 |      50000 |         0.00 | 4096 kB
--  dba_metrics      | table_size_snapshots    |        1 |          |         25 |              | 16 kB
--  dba_metrics      | database_size_snapshots |        1 |          |          7 |              | 16 kB
--  migration_v2_lab | partitioned_events      |        0 |        0 |          0 |              | 0 bytes
--  dba_metrics      | index_size_snapshots    |        0 |          |         21 |              | 16 kB
--  migration_v2_lab | mv_daily_order_volume   |        0 |          |          1 |              | 24 kB
--  dba_metrics      | connection_snapshots    |        0 |          |          3 |              | 16 kB
--  public           | pgbench_history         |        0 |          |    5331130 |              | 270 MB
--  dba_metrics      | wal_snapshots           |        0 |          |          1 |              | 16 kB
-- (32 rows)
-- 
-- SAMPLE_OUTPUT_END
