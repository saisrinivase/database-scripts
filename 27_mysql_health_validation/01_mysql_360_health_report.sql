/*
MySQL DBA Script: Mysql 360 Health Report
Purpose: Provide MySQL DBA diagnostics for mysql 360 health report.
Area: Mysql Health Validation
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Mysql 360 Health Report') AS script_name;

SELECT 'Server inventory' AS section_name, 1 AS finding_count
UNION ALL SELECT 'Long transactions', COUNT(*) FROM information_schema.innodb_trx WHERE TIMESTAMPDIFF(SECOND, trx_started, NOW()) > 300
UNION ALL SELECT 'Replication worker errors', COUNT(*) FROM performance_schema.replication_applier_status_by_worker WHERE last_error_number <> 0
UNION ALL SELECT 'Slow statement digests', COUNT(*) FROM performance_schema.events_statements_summary_by_digest WHERE avg_timer_wait/1000000000000 > 1;
