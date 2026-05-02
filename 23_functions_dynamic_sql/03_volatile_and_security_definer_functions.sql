/*
MySQL DBA Script: Volatile And Security Definer Functions
Purpose: Provide MySQL DBA diagnostics for volatile and security definer functions.
Area: Functions Dynamic Sql
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Volatile And Security Definer Functions') AS script_name;

SELECT routine_schema, routine_name, routine_type, security_type, deterministic, sql_data_access, created, last_altered
FROM information_schema.routines
WHERE routine_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY routine_schema, routine_name;
