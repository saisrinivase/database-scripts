/*
MySQL DBA Script: Enterprise Takeover Gate
Purpose: Provide MySQL DBA diagnostics for enterprise takeover gate.
Area: Mysql Health Validation
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Enterprise Takeover Gate') AS script_name;

SELECT 'REPLICATION_ERRORS' AS gate_name, IF(COUNT(*)=0,'PASS','REVIEW') AS status, COUNT(*) AS finding_count FROM performance_schema.replication_applier_status_by_worker WHERE last_error_number <> 0
UNION ALL SELECT 'LOCK_WAITS', IF(COUNT(*)=0,'PASS','REVIEW'), COUNT(*) FROM information_schema.innodb_lock_waits
UNION ALL SELECT 'LONG_TRANSACTIONS', IF(COUNT(*)=0,'PASS','REVIEW'), COUNT(*) FROM information_schema.innodb_trx WHERE TIMESTAMPDIFF(SECOND, trx_started, NOW()) > 300;
