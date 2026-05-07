/*
PostgreSQL DBA Script: Short Vs Long Query Distribution
Purpose: Classify query mix into short/medium/long buckets for optimization strategy choice.
Area: Long Queries and Full Scans
Usage: Requires pg_stat_statements; thresholds are adjustable.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--       bucket       | statement_count | total_calls | total_exec_time_ms 
-- -------------------+-----------------+-------------+--------------------
--  Short (<10ms)     |             688 |    39301614 | 21138847.442612693
--  Medium (10-100ms) |              68 |         226 |  6928.975448999999
--  Long (100ms-1s)   |              35 |         130 |       36590.310079
--  Very long (>1s)   |               3 |           9 | 10957.114957999998
-- (4 rows)
-- 
-- SAMPLE_OUTPUT_END
