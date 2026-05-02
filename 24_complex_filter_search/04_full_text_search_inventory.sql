/*
MySQL DBA Script: Full Text Search Inventory
Purpose: Provide MySQL DBA diagnostics for full text search inventory.
Area: Complex Filter Search
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Full Text Search Inventory') AS script_name;

SELECT table_schema, table_name, index_name, index_type, column_name
FROM information_schema.statistics
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  AND index_type IN ('FULLTEXT','SPATIAL')
ORDER BY table_schema, table_name, index_name, seq_in_index;
