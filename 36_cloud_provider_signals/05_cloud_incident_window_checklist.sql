/*
MySQL DBA Script: Cloud Incident Window Checklist
Purpose: Provide MySQL DBA diagnostics for cloud incident window checklist.
Area: Cloud Provider Signals
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Cloud Incident Window Checklist') AS script_name;

SELECT 'Capture error log, slow digests, replication lag/errors, storage I/O, changed variables, and cloud maintenance events' AS incident_evidence_item
UNION ALL SELECT 'Check cloud console CPU, IOPS, burst credits, connection limits, and failover events';
