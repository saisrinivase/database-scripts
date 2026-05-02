/*
MySQL DBA Script: Error Signature Indicators
Purpose: Provide MySQL DBA diagnostics for error signature indicators.
Area: Logging Error Signatures
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Error Signature Indicators') AS script_name;

SELECT logged, prio, error_code, subsystem, LEFT(data, 500) AS message
FROM performance_schema.error_log
ORDER BY logged DESC
LIMIT 200;
