/*
MySQL DBA Script: Redo Binlog Checkpoint Settings
Purpose: Provide MySQL DBA diagnostics for redo binlog checkpoint settings.
Area: Configuration Parameters
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Redo Binlog Checkpoint Settings') AS script_name;

SELECT variable_name, variable_value
FROM performance_schema.global_variables
WHERE variable_name IN ('innodb_redo_log_capacity','innodb_log_file_size','innodb_flush_log_at_trx_commit','sync_binlog','log_bin','binlog_format','binlog_expire_logs_seconds')
ORDER BY variable_name;
