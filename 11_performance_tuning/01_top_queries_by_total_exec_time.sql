/*
Purpose: Rank statements by cumulative execution time to identify biggest workload contributors.
Area: Performance Tuning
Usage: Requires pg_stat_statements extension.
*/
SELECT
    queryid,
    calls,
    total_exec_time,
    mean_exec_time,
    rows,
    shared_blks_hit,
    shared_blks_read,
    temp_blks_written,
    left(query, 500) AS query_snippet
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 100;
