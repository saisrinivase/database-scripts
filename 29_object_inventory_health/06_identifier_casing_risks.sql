/*
MySQL DBA Script: Identifier Casing Risks
Purpose: Provide MySQL DBA diagnostics for identifier casing risks.
Area: Object Inventory Health
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Identifier Casing Risks') AS script_name;

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  AND table_name REGEXP BINARY '[A-Z]'
ORDER BY table_schema, table_name;
