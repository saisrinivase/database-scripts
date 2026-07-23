/*
PostgreSQL DBA Script: Lock Wait Deadlock Signatures
Purpose: Capture active lock-wait chains and deadlock-prone signatures from current activity.
Area: Logging and Error Signatures
Usage: Run during incidents; repeat snapshots to see evolving blockers.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH waiting AS (
    SELECT
        a.pid AS blocked_pid,
        a.usename AS blocked_user,
        a.application_name AS blocked_app,
        a.state AS blocked_state,
        a.wait_event_type,
        a.wait_event,
        now() - a.query_start AS blocked_query_age,
        pg_blocking_pids(a.pid) AS blocker_pids,
        a.query AS blocked_query
    FROM pg_stat_activity a
    WHERE a.wait_event_type = 'Lock'
      AND a.pid <> pg_backend_pid()
),
expanded AS (
    SELECT
        w.blocked_pid,
        w.blocked_user,
        w.blocked_app,
        w.blocked_state,
        w.wait_event_type,
        w.wait_event,
        w.blocked_query_age,
        unnest(w.blocker_pids) AS blocking_pid,
        w.blocked_query
    FROM waiting w
),
blocking AS (
    SELECT
        e.blocked_pid,
        e.blocked_user,
        e.blocked_app,
        e.blocked_state,
        e.wait_event_type,
        e.wait_event,
        e.blocked_query_age,
        e.blocking_pid,
        b.usename AS blocking_user,
        b.application_name AS blocking_app,
        b.state AS blocking_state,
        now() - b.query_start AS blocking_query_age,
        b.query AS blocking_query,
        e.blocked_query
    FROM expanded e
    LEFT JOIN pg_stat_activity b
      ON b.pid = e.blocking_pid
)
SELECT
    blocked_pid,
    blocked_user,
    blocked_app,
    blocked_state,
    wait_event_type,
    wait_event,
    round(extract(epoch FROM blocked_query_age)::numeric, 2) AS blocked_query_age_sec,
    blocking_pid,
    blocking_user,
    blocking_app,
    blocking_state,
    round(extract(epoch FROM blocking_query_age)::numeric, 2) AS blocking_query_age_sec,
    blocked_query,
    blocking_query
FROM blocking
ORDER BY blocked_query_age DESC, blocked_pid;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  blocked_pid | blocked_user | blocked_app | blocked_state | wait_event_type | wait_event | blocked_query_age_sec | blocking_pid | blocking_user | blocking_app | blocking_state | blocking_query_age_sec | blocked_query | blocking_query 
-- -------------+--------------+-------------+---------------+-----------------+------------+-----------------------+--------------+---------------+--------------+----------------+------------------------+---------------+----------------
-- (0 rows)
-- 
-- SAMPLE_OUTPUT_END
