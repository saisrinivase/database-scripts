/*
MySQL DBA Script: Backend Type Distribution
Purpose: Provide MySQL DBA diagnostics for backend type distribution.
Area: Connection Workload
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Backend Type Distribution') AS script_name;

SELECT type, processlist_command, processlist_state, COUNT(*) AS thread_count
FROM performance_schema.threads
GROUP BY type, processlist_command, processlist_state
ORDER BY thread_count DESC;
