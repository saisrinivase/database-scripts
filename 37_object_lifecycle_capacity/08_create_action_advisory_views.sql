/*
MySQL DBA Script: Create Action Advisory Views
Purpose: Provide MySQL DBA diagnostics for create action advisory views.
Area: Object Lifecycle Capacity
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Create Action Advisory Views') AS script_name;

CREATE OR REPLACE VIEW dba_lifecycle_action_advice_v AS
SELECT object_schema, object_name, object_type,
       CASE WHEN rows_estimate IS NULL THEN 'ANALYZE_TABLE' ELSE 'MONITOR' END AS recommended_action
FROM dba_lifecycle_object_snap;
