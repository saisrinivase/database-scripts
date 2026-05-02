/*
MySQL DBA Script: Parameter Pending Restart Drift
Purpose: Provide MySQL DBA diagnostics for parameter pending restart drift.
Area: Cloud Provider Signals
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Parameter Pending Restart Drift') AS script_name;

SELECT variable_name, variable_value, variable_source, set_time, set_user, set_host
FROM performance_schema.variables_info
WHERE variable_source <> 'COMPILED'
ORDER BY variable_name;
