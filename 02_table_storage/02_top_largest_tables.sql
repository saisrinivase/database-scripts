/*
MySQL DBA Script: Top Largest Tables
Purpose: Provide MySQL DBA diagnostics for top largest tables.
Area: Table Storage
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Top Largest Tables') AS script_name;

SELECT table_schema, table_name, engine, table_rows,
       ROUND((data_length + index_length)/1024/1024,2) AS total_mb,
       ROUND(data_length/1024/1024,2) AS data_mb,
       ROUND(index_length/1024/1024,2) AS index_mb,
       ROUND(data_free/1024/1024,2) AS free_mb
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY data_length + index_length DESC
LIMIT 50;
