/*
Purpose: Identify tables where modifications have outpaced analyze activity.
Area: Planner and Statistics
Usage: Use thresholds to prioritize manual ANALYZE or autovacuum tuning.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    n_live_tup,
    n_mod_since_analyze,
    round(100.0 * n_mod_since_analyze / NULLIF(n_live_tup, 0), 2) AS mods_vs_live_pct,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE n_mod_since_analyze > 0
ORDER BY n_mod_since_analyze DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | n_live_tup | n_mod_since_analyze | mods_vs_live_pct |         last_analyze          | last_autoanalyze 
-- ------------------+-------------------------+------------+---------------------+------------------+-------------------------------+------------------
--  public           | pgbench_accounts        |  200000029 |             5332823 |             2.67 | 2026-01-31 21:38:08.216354-05 | 
--  dba_metrics      | table_size_snapshots    |         25 |                  25 |           100.00 |                               | 
--  dba_metrics      | index_size_snapshots    |         21 |                  21 |           100.00 |                               | 
--  migration_v2_lab | issue_manifest          |         11 |                  11 |           100.00 |                               | 
--  dba_metrics      | database_size_snapshots |          7 |                   7 |           100.00 |                               | 
--  dba_metrics      | connection_snapshots    |          3 |                   3 |           100.00 |                               | 
--  migration_v2_lab | mv_daily_order_volume   |          1 |                   2 |           200.00 |                               | 
--  dba_metrics      | wal_snapshots           |          1 |                   1 |           100.00 |                               | 
-- (8 rows)
-- 
-- SAMPLE_OUTPUT_END

