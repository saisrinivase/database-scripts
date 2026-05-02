/*
MySQL DBA Script: Checksum Status And Failures
Purpose: Provide MySQL DBA diagnostics for checksum status and failures.
Area: Consistency Integrity Checks
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Checksum Status And Failures') AS script_name;

SELECT variable_name, variable_value
FROM performance_schema.global_variables
WHERE variable_name IN ('innodb_checksum_algorithm','innodb_doublewrite','innodb_force_recovery')
UNION ALL
SELECT variable_name, variable_value FROM performance_schema.global_status WHERE variable_name LIKE 'Innodb_data_fsyncs';
