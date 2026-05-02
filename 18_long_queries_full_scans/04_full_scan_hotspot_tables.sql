/*
MySQL DBA Script: Full Scan Hotspot Tables
Purpose: Provide MySQL DBA diagnostics for full scan hotspot tables.
Area: Long Queries Full Scans
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Full Scan Hotspot Tables') AS script_name;

SELECT object_schema, object_name, count_read, count_fetch, count_insert, count_update, count_delete
FROM performance_schema.table_io_waits_summary_by_table
WHERE object_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY count_fetch DESC
LIMIT 100;
