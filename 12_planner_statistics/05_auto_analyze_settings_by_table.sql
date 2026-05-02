/*
MySQL DBA Script: Auto Analyze Settings By Table
Purpose: Provide MySQL DBA diagnostics for auto analyze settings by table.
Area: Planner Statistics
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Auto Analyze Settings By Table') AS script_name;

SELECT variable_name, variable_value
FROM performance_schema.global_variables
WHERE variable_name IN ('optimizer_switch','innodb_stats_persistent','innodb_stats_auto_recalc','eq_range_index_dive_limit','range_optimizer_max_mem_size','histogram_generation_max_mem_size')
ORDER BY variable_name;
