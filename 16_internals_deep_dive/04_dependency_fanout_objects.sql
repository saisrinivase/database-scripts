/*
MySQL DBA Script: Dependency Fanout Objects
Purpose: Provide MySQL DBA diagnostics for dependency fanout objects.
Area: Internals Deep Dive
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Dependency Fanout Objects') AS script_name;

SELECT constraint_schema, table_name, constraint_name, referenced_table_schema, referenced_table_name
FROM information_schema.referential_constraints
WHERE constraint_schema NOT IN ('mysql','sys','performance_schema','information_schema')
ORDER BY constraint_schema, table_name;
