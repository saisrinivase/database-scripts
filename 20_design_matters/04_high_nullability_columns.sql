/*
MySQL DBA Script: High Nullability Columns
Purpose: Provide MySQL DBA diagnostics for high nullability columns.
Area: Design Matters
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: High Nullability Columns') AS script_name;

SELECT table_schema, table_name, COUNT(*) AS column_count,
       SUM(is_nullable='YES') AS nullable_columns,
       ROUND(SUM(is_nullable='YES')/COUNT(*)*100,2) AS nullable_pct
FROM information_schema.columns
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
GROUP BY table_schema, table_name
HAVING SUM(is_nullable='YES')/COUNT(*) >= 0.75
ORDER BY nullable_pct DESC, column_count DESC;
