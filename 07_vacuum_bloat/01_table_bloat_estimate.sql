/*
Purpose: Approximate per-table bloat impact using dead tuple density.
Area: Vacuum and Bloat
Usage: Heuristic estimate; validate with deeper tooling for exact bloat.
*/
WITH stats AS (
    SELECT
        s.relid,
        s.schemaname AS schema_name,
        s.relname AS table_name,
        s.n_live_tup,
        s.n_dead_tup,
        pg_total_relation_size(s.relid) AS total_bytes
    FROM pg_stat_user_tables s
)
SELECT
    schema_name,
    table_name,
    total_bytes,
    pg_size_pretty(total_bytes) AS total_pretty,
    n_live_tup,
    n_dead_tup,
    round(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_tuple_pct,
    (n_dead_tup * (total_bytes / NULLIF(n_live_tup + n_dead_tup, 0)))::bigint AS est_bloat_bytes,
    pg_size_pretty((n_dead_tup * (total_bytes / NULLIF(n_live_tup + n_dead_tup, 0)))::bigint) AS est_bloat_pretty
FROM stats
WHERE n_dead_tup > 0
ORDER BY est_bloat_bytes DESC NULLS LAST;
