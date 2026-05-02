/*
MySQL DBA Script: Backup Pitr Configuration Health
Purpose: Provide MySQL DBA diagnostics for backup pitr configuration health.
Area: Backup Restore Pitr Dr
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Backup Pitr Configuration Health') AS script_name;

SELECT variable_name, variable_value
FROM performance_schema.global_variables
WHERE variable_name IN ('log_bin','binlog_format','binlog_expire_logs_seconds','gtid_mode','server_id','datadir','sync_binlog')
ORDER BY variable_name;
