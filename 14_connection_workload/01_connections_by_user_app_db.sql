/*
MySQL DBA Script: Connections By User App Db
Purpose: Provide MySQL DBA diagnostics for connections by user app db.
Area: Connection Workload
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Connections By User App Db') AS script_name;

SELECT user, host, db, command, COUNT(*) AS connections, MAX(time) AS max_seconds
FROM information_schema.processlist
GROUP BY user, host, db, command
ORDER BY connections DESC;
