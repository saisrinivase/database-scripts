/*
MySQL DBA Script: Parameter Tuning Advisor
Purpose: Provide MySQL DBA diagnostics for parameter tuning advisor.
Area: High Speed Tuning
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Parameter Tuning Advisor') AS script_name;

SELECT variable_name, variable_value
FROM performance_schema.global_variables
WHERE variable_name IN ('innodb_buffer_pool_size','innodb_log_buffer_size','tmp_table_size','max_heap_table_size','sort_buffer_size','join_buffer_size','read_rnd_buffer_size')
ORDER BY variable_name;
