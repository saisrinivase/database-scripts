/*
PostgreSQL DBA Script: Wait Event Hotspots
Purpose: Summarize current wait events by type, event, state, backend type, application, and database.
Area: Observability 360
Usage: Run repeatedly during slowdowns to identify whether pressure is lock, IO, LWLock, client, or background-worker related.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only snapshot of current activity.
*/
SELECT
    coalesce(wait_event_type, 'not_waiting') AS wait_event_type,
    coalesce(wait_event, 'not_waiting') AS wait_event,
    coalesce(state, backend_type) AS session_state,
    backend_type,
    coalesce(datname, '(no database)') AS database_name,
    coalesce(usename, '(no user)') AS user_name,
    coalesce(nullif(application_name, ''), '(no application)') AS application_name,
    count(*) AS sessions,
    max(now() - coalesce(query_start, backend_start)) AS oldest_query_or_backend_age,
    max(now() - coalesce(xact_start, query_start, backend_start)) AS oldest_xact_or_query_age
FROM pg_stat_activity
GROUP BY
    coalesce(wait_event_type, 'not_waiting'),
    coalesce(wait_event, 'not_waiting'),
    coalesce(state, backend_type),
    backend_type,
    coalesce(datname, '(no database)'),
    coalesce(usename, '(no user)'),
    coalesce(nullif(application_name, ''), '(no application)')
ORDER BY sessions DESC, oldest_query_or_backend_age DESC NULLS LAST;

-- SAMPLE_OUTPUT_BEGIN
-- wait_event_type | wait_event  | session_state | backend_type   | database_name | sessions | oldest_query_or_backend_age
-- ----------------+-------------+---------------+----------------+---------------+----------+----------------------------
-- not_waiting     | not_waiting | idle          | client backend | appdb         |       25 | 00:12:03
-- Lock            | transactionid| active        | client backend | appdb         |        3 | 00:03:41
-- IO              | DataFileRead| active        | client backend | appdb         |        2 | 00:00:09
-- SAMPLE_OUTPUT_END
