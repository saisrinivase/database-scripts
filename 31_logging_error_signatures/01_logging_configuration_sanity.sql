/*
MySQL DBA Script: Logging Configuration Sanity
Purpose: Provide MySQL DBA diagnostics for logging configuration sanity.
Area: Logging Error Signatures
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Logging Configuration Sanity') AS script_name;

SELECT variable_name, variable_value
FROM performance_schema.global_variables
WHERE variable_name IN ('log_error','log_error_verbosity','slow_query_log','slow_query_log_file','long_query_time','general_log','log_output')
ORDER BY variable_name;
