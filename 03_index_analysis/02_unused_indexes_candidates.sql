/*
MySQL DBA Script: Unused Indexes Candidates
Purpose: Provide MySQL DBA diagnostics for unused indexes candidates.
Area: Index Analysis
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Unused Indexes Candidates') AS script_name;

SELECT s.object_schema, s.object_name AS table_name, s.index_name
FROM performance_schema.table_io_waits_summary_by_index_usage s
WHERE s.index_name IS NOT NULL
  AND s.index_name <> 'PRIMARY'
  AND s.count_star = 0
  AND s.object_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY s.object_schema, s.object_name, s.index_name;
