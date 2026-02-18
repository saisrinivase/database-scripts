/*
Purpose: Find high-latency statements (average execution time) with meaningful call counts.
Area: Performance Tuning
Usage: Requires pg_stat_statements extension; adjust minimum calls threshold.
*/
SELECT
    queryid,
    calls,
    total_exec_time,
    mean_exec_time,
    min_exec_time,
    max_exec_time,
    stddev_exec_time,
    rows,
    left(query, 500) AS query_snippet
FROM pg_stat_statements
WHERE calls >= 50
ORDER BY mean_exec_time DESC
LIMIT 100;
