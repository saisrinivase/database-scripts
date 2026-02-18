/*
Purpose: Rank tables by dead tuple count and dead tuple percentage.
Area: Vacuum and Bloat
Usage: Supports targeting manual VACUUM or autovacuum tuning.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    n_live_tup,
    n_dead_tup,
    round(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_tuple_pct,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC;
