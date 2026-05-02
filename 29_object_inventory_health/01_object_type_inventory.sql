/*
MySQL DBA Script: Object Type Inventory
Purpose: Provide MySQL DBA diagnostics for object type inventory.
Area: Object Inventory Health
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Object Type Inventory') AS script_name;

SELECT table_schema AS schema_name, table_type, COUNT(*) AS object_count
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
GROUP BY table_schema, table_type
UNION ALL
SELECT routine_schema, routine_type, COUNT(*)
FROM information_schema.routines
WHERE routine_schema NOT IN ('mysql','sys','performance_schema','information_schema')
GROUP BY routine_schema, routine_type
ORDER BY schema_name, table_type;
