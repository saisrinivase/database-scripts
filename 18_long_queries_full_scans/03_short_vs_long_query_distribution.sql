/*
Purpose: Classify query mix into short/medium/long buckets for optimization strategy choice.
Area: Long Queries and Full Scans
Usage: Requires pg_stat_statements; thresholds are adjustable.
*/
WITH classified AS (
    SELECT
        CASE
            WHEN mean_exec_time < 10 THEN 'Short (<10ms)'
            WHEN mean_exec_time < 100 THEN 'Medium (10-100ms)'
            WHEN mean_exec_time < 1000 THEN 'Long (100ms-1s)'
            ELSE 'Very long (>1s)'
        END AS bucket,
        calls,
        total_exec_time
    FROM pg_stat_statements
)
SELECT
    bucket,
    count(*) AS statement_count,
    sum(calls) AS total_calls,
    sum(total_exec_time) AS total_exec_time_ms
FROM classified
GROUP BY bucket
ORDER BY
    CASE bucket
        WHEN 'Short (<10ms)' THEN 1
        WHEN 'Medium (10-100ms)' THEN 2
        WHEN 'Long (100ms-1s)' THEN 3
        ELSE 4
    END;
