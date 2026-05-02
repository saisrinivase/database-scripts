/*
MySQL DBA Script: Overindexed Tables
Purpose: Provide MySQL DBA diagnostics for overindexed tables.
Area: Design Matters
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Overindexed Tables') AS script_name;

SELECT table_schema, table_name, COUNT(DISTINCT index_name) AS index_count
FROM information_schema.statistics
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
GROUP BY table_schema, table_name
HAVING COUNT(DISTINCT index_name) >= 6
ORDER BY index_count DESC;
