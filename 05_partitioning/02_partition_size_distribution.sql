/*
MySQL DBA Script: Partition Size Distribution
Purpose: Provide MySQL DBA diagnostics for partition size distribution.
Area: Partitioning
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Partition Size Distribution') AS script_name;

SELECT table_schema, table_name, COUNT(*) AS partition_count,
       ROUND(SUM(data_length+index_length)/1024/1024,2) AS total_mb,
       ROUND(MIN(data_length+index_length)/1024/1024,2) AS min_partition_mb,
       ROUND(MAX(data_length+index_length)/1024/1024,2) AS max_partition_mb
FROM information_schema.partitions
WHERE partition_name IS NOT NULL
  AND table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
GROUP BY table_schema, table_name
ORDER BY total_mb DESC;
