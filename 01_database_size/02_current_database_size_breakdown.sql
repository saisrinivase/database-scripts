/*
MySQL DBA Script: Current Database Size Breakdown
Purpose: Provide MySQL DBA diagnostics for current database size breakdown.
Area: Database Size
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Current Database Size Breakdown') AS script_name;

SELECT 'DATA' AS component, ROUND(SUM(data_length)/1024/1024,2) AS mb FROM information_schema.tables WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
UNION ALL
SELECT 'INDEXES', ROUND(SUM(index_length)/1024/1024,2) FROM information_schema.tables WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
UNION ALL
SELECT 'DATA_FREE_FRAGMENTATION', ROUND(SUM(data_free)/1024/1024,2) FROM information_schema.tables WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
UNION ALL
SELECT 'TEMP_TABLESPACES', ROUND(SUM(file_size)/1024/1024,2) FROM information_schema.innodb_tablespaces WHERE name LIKE 'innodb_temporary%';
