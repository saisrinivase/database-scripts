/*
Purpose: Build an actionable queue of expensive queries with root-cause hints and next actions.
Area: High Speed Tuning
Usage: Requires pg_stat_statements; start with top 20 rows.
*/
SELECT
    queryid,
    calls,
    total_exec_time,
    mean_exec_time,
    stddev_exec_time,
    rows,
    shared_blks_hit,
    shared_blks_read,
    temp_blks_written,
    CASE
        WHEN mean_exec_time >= 1000 AND calls >= 100 THEN 'High latency + high frequency'
        WHEN temp_blks_written > 0 THEN 'Sort/hash spill risk'
        WHEN shared_blks_read > shared_blks_hit THEN 'I/O-bound pattern'
        WHEN calls >= 50000 AND mean_exec_time < 5 THEN 'Chatty/N+1 pattern'
        WHEN stddev_exec_time > mean_exec_time THEN 'Unstable runtime/plan'
        ELSE 'General tuning candidate'
    END AS root_cause_hint,
    CASE
        WHEN mean_exec_time >= 1000 AND calls >= 100 THEN 'Run EXPLAIN ANALYZE; verify index and filter selectivity.'
        WHEN temp_blks_written > 0 THEN 'Increase work_mem carefully and optimize sort/hash path.'
        WHEN shared_blks_read > shared_blks_hit THEN 'Review missing indexes and cache efficiency.'
        WHEN calls >= 50000 AND mean_exec_time < 5 THEN 'Batch at application layer or reduce query round-trips.'
        WHEN stddev_exec_time > mean_exec_time THEN 'Check parameter-sensitive plans and stale statistics.'
        ELSE 'Inspect SQL design, indexes, and configuration context.'
    END AS recommended_next_action,
    left(query, 350) AS query_snippet
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 300;
