/*
PostgreSQL DBA Script: Active Long Queries
Purpose: List currently running long queries and wait signals.
Area: Long Queries and Full Scans
Usage: Run during incidents; adjust threshold interval as needed.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    pid,
    datname AS database_name,
    usename AS user_name,
    application_name,
    client_addr,
    now() - query_start AS query_age,
    state,
    wait_event_type,
    wait_event,
    regexp_replace(query, '\s+', ' ', 'g') AS query_snippet
FROM pg_stat_activity
WHERE state = 'active'
  AND query_start IS NOT NULL
  AND now() - query_start >= interval '1 minute'
ORDER BY query_age DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  pid | database_name | user_name | application_name | client_addr | query_age | state | wait_event_type | wait_event | query_snippet 
-- -----+---------------+-----------+------------------+-------------+-----------+-------+-----------------+------------+---------------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No issue/candidate rows were found at capture time.
-- - This typically indicates healthy state for this check; rerun during peak load for validation.
-- SAMPLE_OUTPUT_END
