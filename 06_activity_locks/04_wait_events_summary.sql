/*
MySQL DBA Script: Wait Events Summary
Purpose: Provide MySQL DBA diagnostics for wait events summary.
Area: Activity Locks
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Wait Events Summary') AS script_name;

SELECT event_name, count_star, sum_timer_wait/1000000000000 AS wait_seconds,
       avg_timer_wait/1000000000000 AS avg_wait_seconds
FROM performance_schema.events_waits_summary_global_by_event_name
WHERE count_star > 0
ORDER BY sum_timer_wait DESC
LIMIT 100;
