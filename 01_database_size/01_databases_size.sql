/*
MySQL DBA Script: Databases Size
Purpose: Provide MySQL DBA diagnostics for databases size.
Area: Database Size
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Databases Size') AS script_name;

SELECT table_schema AS schema_name,
       ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS total_mb,
       ROUND(SUM(data_length) / 1024 / 1024, 2) AS data_mb,
       ROUND(SUM(index_length) / 1024 / 1024, 2) AS index_mb,
       COUNT(*) AS table_count
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
GROUP BY table_schema
ORDER BY total_mb DESC;
