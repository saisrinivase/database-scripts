/*
MySQL DBA Script: Table Pk Fk Health
Purpose: Provide MySQL DBA diagnostics for table pk fk health.
Area: Object Inventory Health
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Table Pk Fk Health') AS script_name;

SELECT t.table_schema, t.table_name,
       SUM(c.constraint_type='PRIMARY KEY') AS pk_count,
       SUM(c.constraint_type='FOREIGN KEY') AS fk_count,
       COUNT(c.constraint_name) AS constraint_count
FROM information_schema.tables t
LEFT JOIN information_schema.table_constraints c ON c.table_schema=t.table_schema AND c.table_name=t.table_name
WHERE t.table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
GROUP BY t.table_schema, t.table_name
ORDER BY fk_count DESC, pk_count, t.table_schema, t.table_name;
