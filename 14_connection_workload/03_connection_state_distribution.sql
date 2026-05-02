/*
MySQL DBA Script: Connection State Distribution
Purpose: Provide MySQL DBA diagnostics for connection state distribution.
Area: Connection Workload
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Connection State Distribution') AS script_name;

SELECT command, state, COUNT(*) AS thread_count, MAX(time) AS max_seconds
FROM information_schema.processlist
GROUP BY command, state
ORDER BY thread_count DESC;
