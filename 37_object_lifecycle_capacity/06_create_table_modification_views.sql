/*
MySQL DBA Script: Create Table Modification Views
Purpose: Provide MySQL DBA diagnostics for create table modification views.
Area: Object Lifecycle Capacity
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Create Table Modification Views') AS script_name;

CREATE OR REPLACE VIEW dba_table_modification_v AS
SELECT object_schema, object_name, count_insert, count_update, count_delete, count_write
FROM performance_schema.table_io_waits_summary_by_table;
