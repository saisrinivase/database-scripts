/*
PostgreSQL DBA Script: Autovacuum Table Status
Purpose: Review vacuum/analyze recency and dead tuples per table.
Area: Vacuum and Bloat
Usage: Focus on large tables with stale vacuum/analyze timestamps.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    vacuum_count,
    autovacuum_count,
    analyze_count,
    autoanalyze_count
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC, n_live_tup DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | n_live_tup | n_dead_tup |          last_vacuum          |        last_autovacuum        |         last_analyze          |       last_autoanalyze        | vacuum_count | autovacuum_count | analyze_count | autoanalyze_count 
-- ------------------+-------------------------+------------+------------+-------------------------------+-------------------------------+-------------------------------+-------------------------------+--------------+------------------+---------------+-------------------
--  public           | pgbench_accounts        |  200000029 |    4232485 | 2026-01-31 21:17:24.785585-05 |                               | 2026-01-31 21:38:08.216354-05 |                               |            1 |                0 |             2 |                 0
--  public           | pgbench_branches        |       2000 |         81 | 2026-01-31 21:39:05.847237-05 | 2026-01-31 21:50:02.975964-05 | 2026-01-31 21:38:08.216654-05 | 2026-01-31 21:50:03.053521-05 |            3 |               11 |             2 |                11
--  public           | pgbench_history         |    5331130 |          0 | 2026-01-31 21:17:26.345526-05 | 2026-01-31 21:47:10.021717-05 | 2026-01-31 21:38:08.216778-05 | 2026-01-31 21:49:09.283716-05 |            1 |                6 |             2 |                 8
--  migration_v2_lab | order_fact              |     300000 |          0 |                               | 2026-02-18 19:40:51.621893-05 | 2026-02-18 19:40:09.596113-05 |                               |            0 |                1 |             2 |                 0
--  migration_v2_lab | child_events            |     250000 |          0 |                               | 2026-02-18 19:40:48.76835-05  | 2026-02-18 19:40:09.054192-05 |                               |            0 |                1 |             2 |                 0
--  migration_v2_lab | stale_stats_table       |     180000 |          0 |                               | 2026-02-18 19:40:50.829722-05 | 2026-02-18 19:40:06.933591-05 |                               |            0 |                1 |             1 |                 0
--  migration_v1_lab | child_transactions      |     120000 |          0 |                               | 2026-02-18 19:40:46.078847-05 | 2026-02-18 19:40:00.318365-05 |                               |            0 |                1 |             1 |                 0
--  migration_v2_lab | sales_catalog           |     120000 |          0 |                               | 2026-02-18 19:40:48.867779-05 | 2026-02-18 19:40:09.154621-05 |                               |            0 |                1 |             2 |                 0
--  migration_v2_lab | amount_mapping_risk     |     120000 |          0 |                               | 2026-02-18 19:40:51.266171-05 | 2026-02-18 19:40:09.287421-05 |                               |            0 |                1 |             2 |                 0
--  migration_v2_lab | customer_contact_compat |      90000 |          0 |                               | 2026-02-18 19:40:50.993265-05 | 2026-02-18 19:40:09.270003-05 |                               |            0 |                1 |             2 |                 0
--  migration_v1_lab | stale_stats_table       |      60000 |          0 |                               | 2026-02-18 19:40:47.122908-05 | 2026-02-18 19:40:00.560317-05 |                               |            0 |                1 |             1 |                 0
--  migration_v2_lab | customer_staging_no_pk  |      60000 |          0 |                               | 2026-02-18 19:40:47.308377-05 | 2026-02-18 19:40:08.952862-05 |                               |            0 |                1 |             2 |                 0
--  migration_v2_lab | partitioned_events_2025 |      52194 |          0 |                               | 2026-02-18 19:40:51.315075-05 | 2026-02-18 19:40:09.744309-05 |                               |            0 |                1 |             2 |                 0
--  migration_v2_lab | parent_accounts         |      50000 |          0 |                               | 2026-02-18 19:40:47.612358-05 | 2026-02-18 19:40:09.031562-05 |                               |            0 |                1 |             2 |                 0
--  migration_v1_lab | product_catalog         |      50000 |          0 |                               | 2026-02-18 19:40:46.43799-05  | 2026-02-18 19:40:00.403662-05 |                               |            0 |                1 |             1 |                 0
--  migration_v2_lab | partitioned_events_2026 |      47806 |          0 |                               | 2026-02-18 19:40:51.653392-05 | 2026-02-18 19:40:09.81939-05  |                               |            0 |                1 |             2 |                 0
--  migration_v2_lab | bloat_pressure_table    |      42000 |          0 | 2026-02-18 19:40:06.945146-05 |                               | 2026-02-18 19:40:06.95025-05  |                               |            1 |                0 |             1 |                 0
--  public           | pgbench_tellers         |      20000 |          0 | 2026-01-31 21:39:05.847568-05 | 2026-01-31 21:50:03.101745-05 | 2026-01-31 21:38:08.217672-05 | 2026-01-31 21:50:03.137348-05 |            3 |               11 |             2 |                11
--  migration_v1_lab | dml_bloat_table         |      12000 |          0 | 2026-02-18 19:40:00.562767-05 |                               | 2026-02-18 19:40:00.563283-05 |                               |            1 |                0 |             1 |                 0
--  migration_v1_lab | parent_accounts         |      10000 |          0 |                               | 2026-02-18 19:40:45.158556-05 | 2026-02-18 19:40:00.302257-05 |                               |            0 |                1 |             1 |                 0
--  migration_v1_lab | orders_no_pk            |      10000 |          0 |                               | 2026-02-18 19:40:45.10605-05  | 2026-02-18 19:40:00.281218-05 |                               |            0 |                1 |             1 |                 0
--  migration_v2_lab | quoted_orders           |       5000 |          0 |                               | 2026-02-18 19:40:48.880065-05 | 2026-02-18 19:40:09.835093-05 |                               |            0 |                1 |             2 |                 0
--  migration_v1_lab | sales_orders            |       1000 |          0 |                               |                               | 2026-02-18 19:40:00.406304-05 |                               |            0 |                0 |             1 |                 0
--  dba_metrics      | table_size_snapshots    |         25 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
--  dba_metrics      | index_size_snapshots    |         21 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
--  migration_v2_lab | issue_manifest          |         11 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
--  dba_metrics      | database_size_snapshots |          7 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
--  dba_metrics      | connection_snapshots    |          3 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
--  migration_v2_lab | mv_daily_order_volume   |          1 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
--  dba_metrics      | wal_snapshots           |          1 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
--  migration_v2_lab | partitioned_events      |          0 |          0 |                               |                               | 2026-02-18 19:40:09.672425-05 |                               |            0 |                0 |             2 |                 0
--  migration_v2_lab | trigger_audit_demo      |          0 |          0 |                               |                               | 2026-02-18 19:40:06.737107-05 |                               |            0 |                0 |             1 |                 0
-- (32 rows)
-- 
-- SAMPLE_OUTPUT_END
