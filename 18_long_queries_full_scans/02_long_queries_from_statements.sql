/*
Purpose: Rank historically slow queries using mean and total execution times.
Area: Long Queries and Full Scans
Usage: Requires pg_stat_statements.
*/
SELECT
    queryid,
    calls,
    total_exec_time,
    mean_exec_time,
    min_exec_time,
    max_exec_time,
    shared_blks_read,
    temp_blks_written,
    left(query, 400) AS query_snippet
FROM pg_stat_statements
WHERE calls >= 5
ORDER BY mean_exec_time DESC
LIMIT 100;
