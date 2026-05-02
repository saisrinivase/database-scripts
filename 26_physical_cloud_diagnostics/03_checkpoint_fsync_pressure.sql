/*
MySQL DBA Script: Checkpoint Fsync Pressure
Purpose: Provide MySQL DBA diagnostics for checkpoint fsync pressure.
Area: Physical Cloud Diagnostics
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Checkpoint Fsync Pressure') AS script_name;

SELECT variable_name, variable_value
FROM performance_schema.global_status
WHERE variable_name IN ('Innodb_checkpoint_age','Innodb_buffer_pool_pages_dirty','Innodb_buffer_pool_bytes_dirty','Innodb_os_log_written','Innodb_log_waits')
ORDER BY variable_name;
