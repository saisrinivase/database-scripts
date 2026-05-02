/*
MySQL DBA Script: Dynamic Sql Function Inventory
Purpose: Provide MySQL DBA diagnostics for dynamic sql function inventory.
Area: Functions Dynamic Sql
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Dynamic Sql Function Inventory') AS script_name;

SELECT routine_schema, routine_name, routine_type, LEFT(routine_definition, 500) AS routine_definition
FROM information_schema.routines
WHERE routine_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  AND (UPPER(routine_definition) LIKE '%PREPARE %' OR UPPER(routine_definition) LIKE '%EXECUTE %')
ORDER BY routine_schema, routine_name;
