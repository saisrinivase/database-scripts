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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name | function_name | calls | total_time | self_time | mean_time 
-- -------------+---------------+-------+------------+-----------+-----------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No matching rows were returned at capture time.
-- - Rerun during peak workload or after seeding representative test cases for non-zero examples.
-- SAMPLE_OUTPUT_END
