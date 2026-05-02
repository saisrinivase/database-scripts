/*
MySQL DBA Script: Query Tuning Action Queue
Purpose: Provide MySQL DBA diagnostics for query tuning action queue.
Area: High Speed Tuning
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Query Tuning Action Queue') AS script_name;

SELECT 'TOP_STATEMENT' AS action_type, digest AS target_id, 'Review digest, plan, indexes, and rows examined' AS recommended_action
FROM performance_schema.events_statements_summary_by_digest
WHERE digest IS NOT NULL
ORDER BY sum_timer_wait DESC
LIMIT 50;
