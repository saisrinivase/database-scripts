/*
MySQL DBA Script: User Defined Type Inventory
Purpose: Provide MySQL DBA diagnostics for user defined type inventory.
Area: Object Inventory Health
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: User Defined Type Inventory') AS script_name;

SELECT table_schema, data_type, COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
GROUP BY table_schema, data_type
ORDER BY table_schema, column_count DESC;
