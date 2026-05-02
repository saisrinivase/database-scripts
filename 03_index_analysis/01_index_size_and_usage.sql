/*
MySQL DBA Script: Index Size And Usage
Purpose: Provide MySQL DBA diagnostics for index size and usage.
Area: Index Analysis
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Index Size And Usage') AS script_name;

SELECT table_schema, table_name, index_name, non_unique,
       seq_in_index, column_name, cardinality, nullable, index_type, collation
FROM information_schema.statistics
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY table_schema, table_name, index_name, seq_in_index;
