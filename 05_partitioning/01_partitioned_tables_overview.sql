/*
MySQL DBA Script: Partitioned Tables Overview
Purpose: Provide MySQL DBA diagnostics for partitioned tables overview.
Area: Partitioning
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Partitioned Tables Overview') AS script_name;

SELECT table_schema, table_name, partition_name, subpartition_name, partition_method,
       partition_expression, partition_description, table_rows,
       ROUND((data_length+index_length)/1024/1024,2) AS partition_mb
FROM information_schema.partitions
WHERE partition_name IS NOT NULL
  AND table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY table_schema, table_name, partition_ordinal_position;
