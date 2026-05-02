/*
MySQL DBA Script: Parallel Worker Pressure
Purpose: Provide MySQL DBA diagnostics for parallel worker pressure.
Area: Innodb Memory Pressure
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Parallel Worker Pressure') AS script_name;

SELECT name, type, enabled, timed
FROM performance_schema.setup_instruments
WHERE name LIKE 'thread/%'
ORDER BY name;
