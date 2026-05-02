/*
MySQL DBA Script: Tables With Lobs
Purpose: Provide MySQL DBA diagnostics for tables with lobs.
Area: Lob Blob Storage
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Tables With Lobs') AS script_name;

SELECT c.table_schema, c.table_name, c.column_name, c.data_type, c.character_maximum_length,
       t.engine, t.row_format, ROUND((t.data_length+t.index_length)/1024/1024,2) AS table_mb
FROM information_schema.columns c
JOIN information_schema.tables t ON t.table_schema = c.table_schema AND t.table_name = c.table_name
WHERE c.table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  AND c.data_type IN ('blob','tinyblob','mediumblob','longblob','text','tinytext','mediumtext','longtext','json')
ORDER BY table_mb DESC, c.table_schema, c.table_name, c.column_name;
