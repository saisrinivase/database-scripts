/*
MySQL DBA Script: Deprecated Variable Settings
Purpose: Provide MySQL DBA diagnostics for deprecated variable settings.
Area: Upgrade Patch Readiness
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Deprecated Variable Settings') AS script_name;

SELECT variable_name, variable_value
FROM performance_schema.global_variables
WHERE variable_name IN ('old','sql_mode','default_authentication_plugin','explicit_defaults_for_timestamp','character_set_server','collation_server')
ORDER BY variable_name;
