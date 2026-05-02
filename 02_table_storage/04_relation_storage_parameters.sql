/*
MySQL DBA Script: Relation Storage Parameters
Purpose: Provide MySQL DBA diagnostics for relation storage parameters.
Area: Table Storage
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Relation Storage Parameters') AS script_name;

SELECT table_schema, table_name, engine, row_format, create_options,
       table_collation, avg_row_length, table_rows, data_length, index_length, data_free,
       create_time, update_time
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY table_schema, table_name;
