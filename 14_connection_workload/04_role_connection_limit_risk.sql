/*
MySQL DBA Script: Role Connection Limit Risk
Purpose: Provide MySQL DBA diagnostics for role connection limit risk.
Area: Connection Workload
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Role Connection Limit Risk') AS script_name;

SELECT variable_name, variable_value
FROM performance_schema.global_status
WHERE variable_name IN ('Threads_connected','Threads_running','Max_used_connections','Connection_errors_max_connections')
UNION ALL
SELECT variable_name, variable_value
FROM performance_schema.global_variables
WHERE variable_name IN ('max_connections','thread_cache_size');
