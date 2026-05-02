/*
MySQL DBA Script: Tables Without Primary Keys
Purpose: Provide MySQL DBA diagnostics for tables without primary keys.
Area: Design Matters
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Tables Without Primary Keys') AS script_name;

SELECT t.table_schema, t.table_name, t.engine, t.table_rows
FROM information_schema.tables t
LEFT JOIN information_schema.table_constraints c
  ON c.table_schema=t.table_schema AND c.table_name=t.table_name AND c.constraint_type='PRIMARY KEY'
WHERE t.table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  AND t.table_type='BASE TABLE'
  AND c.constraint_name IS NULL
ORDER BY t.table_rows DESC;
