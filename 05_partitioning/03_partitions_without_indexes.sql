/*
MySQL DBA Script: Partitions Without Indexes
Purpose: Provide MySQL DBA diagnostics for partitions without indexes.
Area: Partitioning
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Partitions Without Indexes') AS script_name;

SELECT p.table_schema, p.table_name, COUNT(DISTINCT s.index_name) AS index_count
FROM information_schema.partitions p
LEFT JOIN information_schema.statistics s ON s.table_schema = p.table_schema AND s.table_name = p.table_name
WHERE p.partition_name IS NOT NULL
  AND p.table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
GROUP BY p.table_schema, p.table_name
HAVING COUNT(DISTINCT s.index_name) = 0
ORDER BY p.table_schema, p.table_name;
