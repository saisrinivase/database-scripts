/*
MySQL DBA Script: Active Sessions
Purpose: Provide MySQL DBA diagnostics for active sessions.
Area: Activity Locks
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Active Sessions') AS script_name;

SELECT id, user, host, db, command, time AS seconds_in_state, state, LEFT(info, 200) AS current_sql
FROM information_schema.processlist
ORDER BY time DESC;
