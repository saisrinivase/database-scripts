/*
MySQL DBA Script: Plan Capture Prerequisites
Purpose: Provide MySQL DBA diagnostics for plan capture prerequisites.
Area: Execution Plans
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Plan Capture Prerequisites') AS script_name;

SELECT @@version AS mysql_version, @@optimizer_switch AS optimizer_switch, @@performance_schema AS performance_schema_enabled;
