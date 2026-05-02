/*
MySQL DBA Script: Capture Snapshot Now
Purpose: Provide MySQL DBA diagnostics for capture snapshot now.
Area: Object Lifecycle Capacity
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Capture Snapshot Now') AS script_name;

CALL capture_dba_lifecycle_snapshot();
