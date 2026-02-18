/*
Purpose: List active and idle sessions with query age and wait details.
Area: Activity and Locks
Usage: Useful for live triage of load or stuck sessions.
*/
SELECT
    a.pid,
    a.usename AS user_name,
    a.application_name,
    a.client_addr,
    a.backend_start,
    a.xact_start,
    a.query_start,
    now() - a.query_start AS query_age,
    a.state,
    a.wait_event_type,
    a.wait_event,
    left(a.query, 400) AS query_snippet
FROM pg_stat_activity a
WHERE a.pid <> pg_backend_pid()
ORDER BY query_age DESC NULLS LAST;
