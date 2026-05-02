/*
MySQL DBA Script: Routine View Alias Mapping
Purpose: Provide MySQL DBA diagnostics for routine view alias mapping.
Area: Object Inventory Health
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Routine View Alias Mapping') AS script_name;

SELECT table_schema AS object_schema, table_name AS object_name, table_type AS object_type
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema') AND table_type='VIEW'
UNION ALL
SELECT routine_schema, routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY object_schema, object_name;
