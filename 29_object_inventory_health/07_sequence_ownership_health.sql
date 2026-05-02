/*
MySQL DBA Script: Sequence Ownership Health
Purpose: Provide MySQL DBA diagnostics for sequence ownership health.
Area: Object Inventory Health
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Sequence Ownership Health') AS script_name;

SELECT table_schema, table_name, column_name, extra
FROM information_schema.columns
WHERE extra LIKE '%auto_increment%'
ORDER BY table_schema, table_name, column_name;
