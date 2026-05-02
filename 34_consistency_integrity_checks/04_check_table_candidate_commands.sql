/*
MySQL DBA Script: Check Table Candidate Commands
Purpose: Provide MySQL DBA diagnostics for check table candidate commands.
Area: Consistency Integrity Checks
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Check Table Candidate Commands') AS script_name;

SELECT CONCAT('CHECK TABLE `', table_schema, '`.`', table_name, '`;') AS check_table_command
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  AND table_type='BASE TABLE'
ORDER BY table_schema, table_name;
