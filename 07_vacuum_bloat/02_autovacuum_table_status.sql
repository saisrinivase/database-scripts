/*
Purpose: Review vacuum/analyze recency and dead tuples per table.
Area: Vacuum and Bloat
Usage: Focus on large tables with stale vacuum/analyze timestamps.
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
