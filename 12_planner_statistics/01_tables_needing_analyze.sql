/*
MySQL DBA Script: Tables Needing Analyze
Purpose: Provide MySQL DBA diagnostics for tables needing analyze.
Area: Planner Statistics
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Tables Needing Analyze') AS script_name;

SELECT table_schema, table_name, engine, table_rows, update_time, check_time,
       CONCAT('ANALYZE TABLE `', table_schema, '`.`', table_name, '`;') AS analyze_command
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  AND table_type='BASE TABLE'
ORDER BY update_time IS NULL DESC, update_time;
