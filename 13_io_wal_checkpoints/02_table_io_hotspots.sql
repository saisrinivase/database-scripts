/*
PostgreSQL DBA Script: Table IO Hotspots
Purpose: Identify tables with highest physical I/O pressure.
Area: I/O, WAL, and Checkpoints
Usage: Correlate with query plans and index strategy.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    heap_blks_read,
    heap_blks_hit,
    idx_blks_read,
    idx_blks_hit,
    toast_blks_read,
    toast_blks_hit,
    tidx_blks_read,
    tidx_blks_hit,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_statio_user_tables
ORDER BY heap_blks_read DESC, idx_blks_read DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | heap_blks_read | heap_blks_hit | idx_blks_read | idx_blks_hit | toast_blks_read | toast_blks_hit | tidx_blks_read | tidx_blks_hit | total_size 
-- ------------------+-------------------------+----------------+---------------+---------------+--------------+-----------------+----------------+----------------+---------------+------------
--  public           | pgbench_accounts        |        8716689 |      30324707 |       5284549 |     48065052 |                 |                |                |               | 30 GB
--  public           | pgbench_history         |         189340 |       5565865 |               |              |                 |                |                |               | 270 MB
--  public           | pgbench_branches        |          13820 |      18525700 |            19 |     11553010 |                 |                |                |               | 7048 kB
--  migration_v2_lab | bloat_pressure_table    |           3742 |        143215 |           249 |       180629 |               0 |              0 |              1 |             0 | 14 MB
--  migration_v2_lab | child_events            |           2929 |        511660 |             3 |       401022 |               0 |              0 |              0 |             0 | 25 MB
--  migration_v2_lab | stale_stats_table       |           2533 |        190328 |             2 |       329876 |               0 |              0 |              0 |             0 | 24 MB
--  public           | pgbench_tellers         |           1774 |      16253894 |            68 |     10830598 |                 |                |                |               | 3712 kB
--  migration_v2_lab | customer_contact_compat |           1227 |        305094 |           249 |       299621 |               0 |              0 |              0 |             0 | 13 MB
--  migration_v2_lab | amount_mapping_risk     |           1109 |        615109 |           285 |       571342 |                 |                |                |               | 19 MB
--  migration_v1_lab | child_transactions      |            886 |        244413 |             3 |       239922 |                 |                |                |               | 11 MB
--  migration_v1_lab | stale_stats_table       |            802 |         63199 |             2 |       119758 |               0 |              0 |              0 |             0 | 7768 kB
--  migration_v2_lab | customer_staging_no_pk  |            659 |         62534 |             1 |            0 |               0 |              0 |              0 |             0 | 5016 kB
--  migration_v2_lab | parent_accounts         |            483 |        551726 |             2 |       599731 |               0 |              0 |              0 |             0 | 4096 kB
--  migration_v1_lab | product_catalog         |            420 |         52500 |             3 |        99731 |               0 |              0 |              0 |             0 | 6032 kB
--  migration_v1_lab | orders_no_pk            |             77 |         10368 |             1 |            0 |               0 |              0 |              0 |             0 | 872 kB
--  migration_v1_lab | parent_accounts         |             67 |        250254 |             2 |       259622 |               0 |              0 |              0 |             0 | 792 kB
--  migration_v2_lab | sales_catalog           |              3 |        127998 |             3 |       239922 |               0 |              0 |              0 |             0 | 14 MB
--  migration_v2_lab | quoted_orders           |              3 |          5244 |             2 |         9608 |               0 |              0 |              0 |             0 | 496 kB
--  migration_v2_lab | order_fact              |              1 |        334100 |             3 |       451849 |               0 |              0 |              0 |             0 | 49 MB
--  migration_v2_lab | partitioned_events_2026 |              1 |         51382 |             1 |        95507 |               0 |              0 |              0 |             0 | 5104 kB
--  migration_v2_lab | partitioned_events_2025 |              1 |         56098 |             1 |       104299 |               0 |              0 |              0 |             0 | 5560 kB
--  migration_v2_lab | mv_daily_order_volume   |              0 |             0 |               |              |               0 |              0 |              0 |             0 | 24 kB
--  dba_metrics      | database_size_snapshots |              0 |             7 |               |              |               0 |              0 |              0 |             0 | 16 kB
--  dba_metrics      | table_size_snapshots    |              0 |            25 |               |              |               0 |              0 |              0 |             0 | 16 kB
--  dba_metrics      | index_size_snapshots    |              0 |            20 |               |              |               0 |              0 |              0 |             0 | 16 kB
--  dba_metrics      | connection_snapshots    |              0 |             2 |               |              |               0 |              0 |              0 |             0 | 16 kB
--  dba_metrics      | wal_snapshots           |              0 |             0 |               |              |               0 |              0 |              0 |             0 | 16 kB
--  migration_v1_lab | dml_bloat_table         |              0 |         40752 |             1 |        49947 |               0 |              0 |              1 |             0 | 4248 kB
--  migration_v1_lab | sales_orders            |              0 |          1017 |             1 |         1597 |               0 |              0 |              0 |             0 | 128 kB
--  migration_v2_lab | issue_manifest          |              0 |            10 |             1 |           12 |               0 |              0 |              0 |             0 | 32 kB
--  migration_v2_lab | trigger_audit_demo      |              0 |             0 |             0 |            0 |               0 |              0 |              0 |             0 | 16 kB
-- (31 rows)
-- 
-- SAMPLE_OUTPUT_END
