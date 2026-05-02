/*
MySQL DBA Script: Table Fragmentation Estimate
Purpose: Provide MySQL DBA diagnostics for table fragmentation estimate.
Area: Table Fragmentation Reclaim
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Table Fragmentation Estimate') AS script_name;

SELECT table_schema, table_name, engine,
       ROUND(data_free/1024/1024,2) AS free_mb,
       ROUND((data_length+index_length)/1024/1024,2) AS total_mb,
       ROUND(data_free / NULLIF(data_length + index_length + data_free,0) * 100,2) AS free_pct,
       CONCAT('OPTIMIZE TABLE `', table_schema, '`.`', table_name, '`;') AS review_command
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  AND data_free > 0
ORDER BY data_free DESC;
