/*
MySQL DBA Script: Insert Copy Activity
Purpose: Provide MySQL DBA diagnostics for insert copy activity.
Area: Object Inventory Health
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Insert Copy Activity') AS script_name;

SELECT object_schema, object_name, count_insert, count_update, count_delete,
       count_write, sum_timer_write/1000000000000 AS write_seconds
FROM performance_schema.table_io_waits_summary_by_table
WHERE object_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY count_write DESC
LIMIT 100;
