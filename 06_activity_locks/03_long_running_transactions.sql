/*
PostgreSQL DBA Script: Long Running Transactions
Purpose: Detect long-running transactions that can block VACUUM and generate bloat.
Area: Activity and Locks
Usage: Adjust interval threshold as needed.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    pid,
    usename AS user_name,
    application_name,
    client_addr,
    xact_start,
    now() - xact_start AS xact_age,
    state,
    wait_event_type,
    wait_event,
    regexp_replace(query, '\s+', ' ', 'g') AS query_snippet
FROM pg_stat_activity
WHERE xact_start IS NOT NULL
  AND now() - xact_start >= interval '5 minutes'
ORDER BY xact_age DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  pid | user_name | application_name | client_addr | xact_start | xact_age | state | wait_event_type | wait_event | query_snippet 
-- -----+-----------+------------------+-------------+------------+----------+-------+-----------------+------------+---------------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No issue/candidate rows were found at capture time.
-- - This typically indicates healthy state for this check; rerun during peak load for validation.
-- SAMPLE_OUTPUT_END
