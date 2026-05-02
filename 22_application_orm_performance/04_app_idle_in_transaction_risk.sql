/*
MySQL DBA Script: App Idle In Transaction Risk
Purpose: Provide MySQL DBA diagnostics for app idle in transaction risk.
Area: Application Orm Performance
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: App Idle In Transaction Risk') AS script_name;

SELECT id, user, host, db, command, time AS idle_seconds, state
FROM information_schema.processlist
WHERE command='Sleep'
ORDER BY time DESC;
