/*
MySQL DBA Script: Stale Stats Hotspots
Purpose: Provide MySQL DBA diagnostics for stale stats hotspots.
Area: Table Fragmentation Reclaim
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Stale Stats Hotspots') AS script_name;

SELECT table_schema, table_name, table_rows, update_time, check_time,
       CASE WHEN update_time IS NULL THEN 'UNKNOWN_UPDATE_TIME' ELSE 'REVIEW_ANALYZE_TABLE' END AS advice
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  AND table_type = 'BASE TABLE'
ORDER BY update_time IS NULL DESC, update_time;
