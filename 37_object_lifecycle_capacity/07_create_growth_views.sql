/*
MySQL DBA Script: Create Growth Views
Purpose: Provide MySQL DBA diagnostics for create growth views.
Area: Object Lifecycle Capacity
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Create Growth Views') AS script_name;

CREATE OR REPLACE VIEW dba_object_growth_v AS
SELECT object_schema, object_name, object_type, DATE(snap_time) AS snap_day,
       MAX(data_bytes + index_bytes) AS max_bytes
FROM dba_lifecycle_object_snap
GROUP BY object_schema, object_name, object_type, DATE(snap_time);
