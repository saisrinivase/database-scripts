/*
Purpose: Detect analytic-style statements with heavy scans and high resource use.
Area: Optimization Goals (OLTP vs OLAP)
Usage: Candidate list for partitioning, pre-aggregation, or materialized views.
*/
SELECT
    queryid,
    calls,
    total_exec_time,
    mean_exec_time,
    shared_blks_read,
    temp_blks_written,
    rows,
    left(query, 260) AS query_snippet
FROM pg_stat_statements
WHERE mean_exec_time >= 200
   OR shared_blks_read >= 100000
   OR temp_blks_written > 0
ORDER BY total_exec_time DESC
LIMIT 200;
