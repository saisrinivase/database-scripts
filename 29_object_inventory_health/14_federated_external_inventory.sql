/*
MySQL DBA Script: Federated External Inventory
Purpose: Provide MySQL DBA diagnostics for federated external inventory.
Area: Object Inventory Health
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Federated External Inventory') AS script_name;

SELECT table_schema, table_name, engine, create_options
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  AND (engine='FEDERATED' OR create_options LIKE '%connection%')
ORDER BY table_schema, table_name;
