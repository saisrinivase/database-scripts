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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

      bucket       | statement_count | total_calls | total_exec_time_ms 
-------------------+-----------------+-------------+--------------------
 Short (<10ms)     |             346 |    38060766 | 21136572.523184724
 Medium (10-100ms) |              27 |          95 | 2270.3437449999997
 Long (100ms-1s)   |              15 |          45 |  9995.503952999998
 Very long (>1s)   |               1 |           1 |        1674.504167
(4 rows)


SAMPLE_OUTPUT_END */
