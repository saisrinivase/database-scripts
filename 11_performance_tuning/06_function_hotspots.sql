/*
MySQL DBA Script: Function Hotspots
Purpose: Provide MySQL DBA diagnostics for function hotspots.
Area: Performance Tuning
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Function Hotspots') AS script_name;

SELECT routine_schema, routine_name, routine_type, data_type, security_type, deterministic, created, last_altered
FROM information_schema.routines
WHERE routine_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY routine_schema, routine_name;
