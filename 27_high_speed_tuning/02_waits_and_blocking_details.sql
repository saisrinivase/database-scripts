/*
Purpose: Show wait profile and blocker/blocked chains for immediate bottleneck diagnosis.
Area: High Speed Tuning
Usage: Run during slowdowns; focus first on blockers with oldest blocked age.
*/
WITH blocked AS (
    SELECT
        a.pid AS blocked_pid,
        a.usename AS blocked_user,
        a.application_name AS blocked_app,
        a.datname AS blocked_database,
        now() - a.query_start AS blocked_query_age,
        left(a.query, 220) AS blocked_query,
        unnest(pg_blocking_pids(a.pid)) AS blocker_pid
    FROM pg_stat_activity a
)
SELECT
    b.blocked_pid,
    b.blocked_user,
    b.blocked_app,
    b.blocked_database,
    b.blocked_query_age,
    b.blocked_query,
    p.pid AS blocker_pid,
    p.usename AS blocker_user,
    p.application_name AS blocker_app,
    p.state AS blocker_state,
    now() - p.query_start AS blocker_query_age,
    left(p.query, 220) AS blocker_query,
    p.wait_event_type AS blocker_wait_type,
    p.wait_event AS blocker_wait_event
FROM blocked b
JOIN pg_stat_activity p
    ON p.pid = b.blocker_pid
ORDER BY b.blocked_query_age DESC NULLS LAST;
