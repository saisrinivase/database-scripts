/*
MySQL DBA Script: Health Sanity Checks
Purpose: Provide MySQL DBA diagnostics for health sanity checks.
Area: Mysql Health Validation
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Health Sanity Checks') AS script_name;

SELECT 'TABLES_WITHOUT_PRIMARY_KEY' AS check_name, COUNT(*) AS finding_count FROM sys.schema_table_statistics_with_buffer WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
UNION ALL SELECT 'LOCK_WAITS', COUNT(*) FROM information_schema.innodb_lock_waits
UNION ALL SELECT 'LONG_TRANSACTIONS', COUNT(*) FROM information_schema.innodb_trx WHERE TIMESTAMPDIFF(SECOND, trx_started, NOW()) > 300
UNION ALL SELECT 'FRAGMENTED_TABLES', COUNT(*) FROM information_schema.tables WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema') AND data_free > 0;
