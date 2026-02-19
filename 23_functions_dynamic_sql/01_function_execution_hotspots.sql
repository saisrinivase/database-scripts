/*
Purpose: Rank user functions by execution cost.
Area: Functions and Dynamic SQL
Usage: Enable track_functions for complete timing data.
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
LIMIT 200;




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
