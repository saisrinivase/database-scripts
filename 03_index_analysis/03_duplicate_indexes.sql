/*
MySQL DBA Script: Duplicate Indexes
Purpose: Provide MySQL DBA diagnostics for duplicate indexes.
Area: Index Analysis
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Duplicate Indexes') AS script_name;

WITH idx AS (
  SELECT table_schema, table_name, index_name, non_unique,
         GROUP_CONCAT(column_name ORDER BY seq_in_index) AS columns_key
  FROM information_schema.statistics
  WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  GROUP BY table_schema, table_name, index_name, non_unique
)
SELECT table_schema, table_name, columns_key, COUNT(*) AS index_count,
       GROUP_CONCAT(index_name ORDER BY index_name SEPARATOR ', ') AS indexes
FROM idx
GROUP BY table_schema, table_name, columns_key
HAVING COUNT(*) > 1
ORDER BY index_count DESC, table_schema, table_name;
