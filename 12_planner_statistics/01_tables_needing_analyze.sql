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
