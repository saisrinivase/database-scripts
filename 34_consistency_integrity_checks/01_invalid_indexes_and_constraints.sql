/*
MySQL DBA Script: Invalid Indexes And Constraints
Purpose: Provide MySQL DBA diagnostics for invalid indexes and constraints.
Area: Consistency Integrity Checks
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Invalid Indexes And Constraints') AS script_name;

SELECT table_schema, table_name, engine, table_collation, create_options
FROM information_schema.tables
WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
  AND (engine IS NULL OR table_collation IS NULL)
ORDER BY table_schema, table_name;
