/*
MySQL DBA Script: Create Index Lifecycle Views
Purpose: Provide MySQL DBA diagnostics for create index lifecycle views.
Area: Object Lifecycle Capacity
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Create Index Lifecycle Views') AS script_name;

CREATE OR REPLACE VIEW dba_index_lifecycle_v AS
SELECT table_schema, table_name, index_name, non_unique, cardinality, index_type
FROM information_schema.statistics;
