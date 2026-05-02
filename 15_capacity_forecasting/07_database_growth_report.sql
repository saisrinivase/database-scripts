/*
MySQL DBA Script: Database Growth Report
Purpose: Provide MySQL DBA diagnostics for database growth report.
Area: Capacity Forecasting
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Database Growth Report') AS script_name;

SELECT schema_name, DATE(snap_time) AS snap_day,
       ROUND(MAX(data_bytes+index_bytes)/1024/1024,2) AS total_mb,
       ROUND(MAX(free_bytes)/1024/1024,2) AS free_mb
FROM dba_capacity_schema_snap
GROUP BY schema_name, DATE(snap_time)
ORDER BY snap_day DESC, total_mb DESC;
