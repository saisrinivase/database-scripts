/*
MySQL DBA Script: System Catalog Size Profile
Purpose: Provide MySQL DBA diagnostics for system catalog size profile.
Area: Internals Deep Dive
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: System Catalog Size Profile') AS script_name;

SELECT table_schema, table_name, engine, table_rows,
       ROUND((data_length+index_length)/1024/1024,2) AS total_mb
FROM information_schema.tables
WHERE table_schema IN ('mysql','sys','performance_schema','information_schema')
ORDER BY total_mb DESC;
