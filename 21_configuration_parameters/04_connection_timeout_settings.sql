/*
MySQL DBA Script: Connection Timeout Settings
Purpose: Provide MySQL DBA diagnostics for connection timeout settings.
Area: Configuration Parameters
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Connection Timeout Settings') AS script_name;

SELECT variable_name, variable_value
FROM performance_schema.global_variables
WHERE variable_name IN ('max_connections','connect_timeout','wait_timeout','interactive_timeout','net_read_timeout','net_write_timeout','thread_cache_size','max_user_connections')
ORDER BY variable_name;
