/*
MySQL DBA Script: Capture Binlog Snapshot
Purpose: Provide MySQL DBA diagnostics for capture binlog snapshot.
Area: Capacity Forecasting
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Capture Binlog Snapshot') AS script_name;

SELECT variable_name, variable_value
FROM performance_schema.global_status
WHERE variable_name IN ('Binlog_cache_disk_use','Binlog_cache_use','Binlog_stmt_cache_disk_use','Binlog_stmt_cache_use','Com_show_binlogs')
UNION ALL
SELECT variable_name, variable_value
FROM performance_schema.global_variables
WHERE variable_name IN ('log_bin','binlog_format','sync_binlog','binlog_expire_logs_seconds','gtid_mode');
