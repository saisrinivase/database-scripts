/*
Purpose: Identify expensive user-defined functions by total execution time.
Area: Performance Tuning
Usage: Requires track_functions enabled for non-zero timing counters.
*/
SELECT
    schemaname AS schema_name,
    funcname AS function_name,
    calls,
    total_time,
    self_time,
    CASE WHEN calls = 0 THEN NULL ELSE total_time / calls END AS mean_time
FROM pg_stat_user_functions
ORDER BY total_time DESC
LIMIT 100;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 schema_name | function_name | calls | total_time | self_time | mean_time 
-------------+---------------+-------+------------+-----------+-----------
(0 rows)


SAMPLE_OUTPUT_END */
