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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 schema_name |       table_name        | n_live_tup | n_mod_since_analyze | mods_vs_live_pct | last_analyze |       last_autoanalyze        
-------------+-------------------------+------------+---------------------+------------------+--------------+-------------------------------
 dba_metrics | database_size_snapshots |         42 |                  42 |           100.00 |              | 
 dba_metrics | table_size_snapshots    |        176 |                  34 |            19.32 |              | 2026-02-18 17:37:43.159982-05
 dba_metrics | connection_snapshots    |         30 |                  30 |           100.00 |              | 
 dba_metrics | wal_snapshots           |          6 |                   6 |           100.00 |              | 
(4 rows)


SAMPLE_OUTPUT_END */
