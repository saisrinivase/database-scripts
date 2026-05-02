/*
MySQL DBA Script: Active Long Queries
Purpose: Provide MySQL DBA diagnostics for active long queries.
Area: Long Queries Full Scans
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Active Long Queries') AS script_name;

SELECT id, user, host, db, command, time AS seconds_running, state, info
FROM information_schema.processlist
WHERE command <> 'Sleep' AND time >= 300
ORDER BY time DESC;
