/*
MySQL DBA Script: Scheduler Runbook
Purpose: Provide MySQL DBA diagnostics for scheduler runbook.
Area: Object Lifecycle Capacity
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Scheduler Runbook') AS script_name;

CREATE EVENT IF NOT EXISTS dba_lifecycle_snapshot_event
ON SCHEDULE EVERY 1 DAY
DO CALL capture_dba_lifecycle_snapshot();
