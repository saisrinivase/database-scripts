/*
MySQL DBA Script: Table Growth Baseline Snapshot
Purpose: Provide MySQL DBA diagnostics for table growth baseline snapshot.
Area: Table Storage
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Table Growth Baseline Snapshot') AS script_name;

SELECT NOW() AS captured_at, table_schema, table_name, engine, table_rows,
       data_length, index_length, data_free, update_time
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY data_length + index_length DESC;
