/*
Purpose: Flag queries with high physical read pressure relative to cache hits.
Area: Performance Tuning
Usage: Requires pg_stat_statements; use with EXPLAIN plans.
*/
WITH base AS (
    SELECT
        queryid,
        calls,
        total_exec_time,
        mean_exec_time,
        shared_blks_hit,
        shared_blks_read,
        local_blks_hit,
        local_blks_read,
        temp_blks_read,
        temp_blks_written,
        left(query, 500) AS query_snippet
    FROM pg_stat_statements
)
SELECT
    queryid,
    calls,
    total_exec_time,
    mean_exec_time,
    shared_blks_read,
    shared_blks_hit,
    round(100.0 * shared_blks_read / NULLIF(shared_blks_read + shared_blks_hit, 0), 2) AS shared_read_pct,
    temp_blks_written,
    query_snippet
FROM base
WHERE calls >= 20
ORDER BY shared_read_pct DESC NULLS LAST, total_exec_time DESC
LIMIT 100;
