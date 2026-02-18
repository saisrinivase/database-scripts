/*
Purpose: Summarize wait events across sessions to spot dominant bottlenecks.
Area: Activity and Locks
Usage: Run repeatedly to compare shifting wait profiles.
*/
SELECT
    coalesce(wait_event_type, 'CPU/None') AS wait_event_type,
    coalesce(wait_event, 'CPU/None') AS wait_event,
    state,
    count(*) AS session_count
FROM pg_stat_activity
GROUP BY coalesce(wait_event_type, 'CPU/None'), coalesce(wait_event, 'CPU/None'), state
ORDER BY session_count DESC, wait_event_type, wait_event;
