/*
MySQL DBA Script: Primary Replication Status
Purpose: Provide MySQL DBA diagnostics for primary replication status.
Area: Replication Ha
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Primary Replication Status') AS script_name;

SELECT channel_name, service_state, last_error_number, last_error_message
FROM performance_schema.replication_connection_status
UNION ALL
SELECT channel_name, service_state, last_error_number, last_error_message
FROM performance_schema.replication_applier_status;
