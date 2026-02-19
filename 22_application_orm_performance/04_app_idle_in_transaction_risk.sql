/*
Purpose: Identify applications holding idle transactions that can block cleanup and increase latency.
Area: Application Development and ORM Performance
Usage: Coordinate fixes with transaction scope in application code.
*/
SELECT
    application_name,
    usename AS user_name,
    datname AS database_name,
    count(*) AS idle_in_txn_sessions,
    min(xact_start) AS oldest_xact_start,
    max(now() - xact_start) AS max_xact_age
FROM pg_stat_activity
WHERE state = 'idle in transaction'
GROUP BY application_name, usename, datname
ORDER BY idle_in_txn_sessions DESC, max_xact_age DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  application_name | user_name | database_name | idle_in_txn_sessions | oldest_xact_start | max_xact_age 
-- ------------------+-----------+---------------+----------------------+-------------------+--------------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No issue/candidate rows were found at capture time.
-- - This typically indicates healthy state for this check; rerun during peak load for validation.
-- SAMPLE_OUTPUT_END
