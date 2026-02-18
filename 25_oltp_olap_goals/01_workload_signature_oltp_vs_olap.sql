/*
Purpose: Classify statement patterns as OLTP-like or OLAP-like based on latency, volume, and rows/call.
Area: Optimization Goals (OLTP vs OLAP)
Usage: Requires pg_stat_statements; heuristic classification.
*/
WITH base AS (
    SELECT
        queryid,
        calls,
        total_exec_time,
        mean_exec_time,
        rows,
        shared_blks_read,
        temp_blks_written,
        CASE WHEN calls = 0 THEN NULL ELSE rows::numeric / calls END AS rows_per_call,
        left(query, 260) AS query_snippet
    FROM pg_stat_statements
)
SELECT
    queryid,
    calls,
    mean_exec_time,
    rows_per_call,
    shared_blks_read,
    temp_blks_written,
    CASE
        WHEN calls >= 5000 AND mean_exec_time < 20 AND coalesce(rows_per_call, 0) <= 10 THEN 'OLTP-like'
        WHEN mean_exec_time >= 200 OR coalesce(rows_per_call, 0) >= 1000 OR temp_blks_written > 0 THEN 'OLAP-like'
        ELSE 'Mixed'
    END AS workload_class,
    query_snippet
FROM base
ORDER BY total_exec_time DESC
LIMIT 300;
