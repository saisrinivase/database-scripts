/*
MySQL DBA Script: Bottleneck Overview Dashboard
Purpose: Provide MySQL DBA diagnostics for bottleneck overview dashboard.
Area: High Speed Tuning
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Bottleneck Overview Dashboard') AS script_name;

SELECT variable_name, variable_value
FROM performance_schema.global_status
WHERE variable_name IN ('Threads_running','Threads_connected','Questions','Queries','Slow_queries','Innodb_buffer_pool_reads','Innodb_buffer_pool_read_requests','Created_tmp_disk_tables','Handler_read_rnd_next')
ORDER BY variable_name;
