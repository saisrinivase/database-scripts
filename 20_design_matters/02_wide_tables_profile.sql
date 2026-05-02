/*
MySQL DBA Script: Wide Tables Profile
Purpose: Provide MySQL DBA diagnostics for wide tables profile.
Area: Design Matters
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Wide Tables Profile') AS script_name;

SELECT table_schema, table_name, COUNT(*) AS column_count,
       SUM(is_nullable='YES') AS nullable_columns
FROM information_schema.columns
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
GROUP BY table_schema, table_name
HAVING COUNT(*) >= 50
ORDER BY column_count DESC;
