/*
Purpose: Flag statements likely to have plan-level issues (spills, I/O-heavy, high variance).
Area: Execution Plans
Usage: Requires pg_stat_statements; candidate list for deeper EXPLAIN ANALYZE.
*/
SELECT
    queryid,
    calls,
    total_exec_time,
    mean_exec_time,
    stddev_exec_time,
    shared_blks_hit,
    shared_blks_read,
    temp_blks_written,
    CASE
        WHEN temp_blks_written > 100000 THEN 'Temp spill risk'
        WHEN shared_blks_read > shared_blks_hit THEN 'I/O heavy plan risk'
        WHEN stddev_exec_time > mean_exec_time THEN 'Unstable plan/runtime variance'
        WHEN mean_exec_time > 1000 THEN 'High latency plan review'
        ELSE 'Observe'
    END AS recommendation,
    left(query, 220) AS query_snippet
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 200;
