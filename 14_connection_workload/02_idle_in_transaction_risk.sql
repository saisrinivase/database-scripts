/*
PostgreSQL DBA Script: Idle In Transaction Risk
Purpose: List idle-in-transaction sessions that can cause bloat and lock retention.
Area: Connection and Workload
Usage: Investigate application transaction handling for recurring offenders.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    pid,
    datname AS database_name,
    usename AS user_name,
    application_name,
    client_addr,
    xact_start,
    state_change,
    now() - xact_start AS xact_age,
    now() - state_change AS idle_in_txn_age,
    wait_event_type,
    wait_event,
    regexp_replace(query, '\s+', ' ', 'g') AS query_snippet
FROM pg_stat_activity
WHERE state = 'idle in transaction'
ORDER BY xact_age DESC NULLS LAST;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  pid | database_name | user_name | application_name | client_addr | xact_start | state_change | xact_age | idle_in_txn_age | wait_event_type | wait_event | query_snippet 
-- -----+---------------+-----------+------------------+-------------+------------+--------------+----------+-----------------+-----------------+------------+---------------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No issue/candidate rows were found at capture time.
-- - This typically indicates healthy state for this check; rerun during peak load for validation.
-- SAMPLE_OUTPUT_END
