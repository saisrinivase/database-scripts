/*
MySQL DBA Script: Column Stats Profile
Purpose: Provide MySQL DBA diagnostics for column stats profile.
Area: Planner Statistics
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Column Stats Profile') AS script_name;

SELECT table_schema, table_name, column_name, data_type, is_nullable, column_key, cardinality
FROM information_schema.columns c
LEFT JOIN information_schema.statistics s
  ON s.table_schema=c.table_schema AND s.table_name=c.table_name AND s.column_name=c.column_name
WHERE c.table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY table_schema, table_name, ordinal_position;
