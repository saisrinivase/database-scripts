/*
MySQL DBA Script: Monthly Capacity Report
Purpose: Provide MySQL DBA diagnostics for monthly capacity report.
Area: Object Lifecycle Capacity
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Monthly Capacity Report') AS script_name;

SELECT object_schema, object_type, snap_day, ROUND(SUM(max_bytes)/1024/1024,2) AS total_mb
FROM dba_object_growth_v
GROUP BY object_schema, object_type, snap_day
ORDER BY snap_day DESC, total_mb DESC;
