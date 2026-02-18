/*
Purpose: Rank expensive SQL statements by total execution time.
Area: Maintenance and Monitoring
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
LIMIT 50;
