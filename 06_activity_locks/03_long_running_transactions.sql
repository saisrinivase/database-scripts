/*
Purpose: Detect long-running transactions that can block VACUUM and generate bloat.
Area: Activity and Locks
Usage: Adjust interval threshold as needed.
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
    left(query, 400) AS query_snippet
FROM pg_stat_activity
WHERE xact_start IS NOT NULL
  AND now() - xact_start >= interval '5 minutes'
ORDER BY xact_age DESC;
