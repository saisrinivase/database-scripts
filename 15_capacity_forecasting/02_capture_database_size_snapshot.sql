/*
MySQL DBA Script: Capture Database Size Snapshot
Purpose: Provide MySQL DBA diagnostics for capture database size snapshot.
Area: Capacity Forecasting
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Capture Database Size Snapshot') AS script_name;

INSERT INTO dba_capacity_schema_snap (schema_name, data_bytes, index_bytes, free_bytes)
SELECT table_schema, SUM(data_length), SUM(index_length), SUM(data_free)
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
GROUP BY table_schema;
