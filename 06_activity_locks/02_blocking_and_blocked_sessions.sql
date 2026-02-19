/*
Purpose: Show blocked sessions and the blocker session details.
Area: Activity and Locks
Usage: Run during lock contention incidents.
*/
SELECT
    blocked.pid AS blocked_pid,
    blocked.usename AS blocked_user,
    blocked.application_name AS blocked_app,
    blocked.state AS blocked_state,
    now() - blocked.query_start AS blocked_query_age,
    left(blocked.query, 300) AS blocked_query,
    blocker.pid AS blocker_pid,
    blocker.usename AS blocker_user,
    blocker.application_name AS blocker_app,
    blocker.state AS blocker_state,
    now() - blocker.query_start AS blocker_query_age,
    left(blocker.query, 300) AS blocker_query
FROM pg_stat_activity blocked
CROSS JOIN LATERAL unnest(pg_blocking_pids(blocked.pid)) AS p(blocker_pid)
JOIN pg_stat_activity blocker
    ON blocker.pid = p.blocker_pid
ORDER BY blocked_query_age DESC NULLS LAST;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  blocked_pid | blocked_user | blocked_app | blocked_state | blocked_query_age | blocked_query | blocker_pid | blocker_user | blocker_app | blocker_state | blocker_query_age | blocker_query 
-- -------------+--------------+-------------+---------------+-------------------+---------------+-------------+--------------+-------------+---------------+-------------------+---------------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No rows matched in this environment at capture time.
-- - This can be expected when the related object/feature is not present or not in use.
-- SAMPLE_OUTPUT_END
