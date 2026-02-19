/*
Purpose: Show top query hotspots with coarse object token extraction from SQL text.
Area: Object Inventory and Health
Usage: Requires pg_stat_statements. Use together with EXPLAIN for final tuning decisions.
*/
SELECT CASE
           WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements')
               THEN 1
           ELSE 0
       END AS has_pgss
\gset

\if :has_pgss
WITH ranked AS (
    SELECT
        s.queryid,
        s.calls,
        s.total_exec_time,
        s.mean_exec_time,
        s.rows,
        s.shared_blks_read,
        s.shared_blks_hit,
        s.temp_blks_written,
        left(s.query, 320) AS query_snippet,
        coalesce(
            substring(lower(s.query) FROM 'from[[:space:]]+([a-z0-9_."$]+)'),
            substring(lower(s.query) FROM 'join[[:space:]]+([a-z0-9_."$]+)')
        ) AS object_token
    FROM pg_stat_statements s
)
SELECT
    queryid,
    calls,
    round(total_exec_time::numeric, 2) AS total_exec_time_ms,
    round(mean_exec_time::numeric, 2) AS mean_exec_time_ms,
    rows,
    shared_blks_read,
    shared_blks_hit,
    temp_blks_written,
    coalesce(object_token, '(unparsed)') AS possible_object,
    query_snippet
FROM ranked
ORDER BY total_exec_time DESC
LIMIT 150;
\else
SELECT
    'pg_stat_statements extension is not installed. Run: CREATE EXTENSION pg_stat_statements;'::text AS guidance;
\endif
