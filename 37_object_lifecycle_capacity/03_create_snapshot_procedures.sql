/*
MySQL DBA Script: Create Snapshot Procedures
Purpose: Provide MySQL DBA diagnostics for create snapshot procedures.
Area: Object Lifecycle Capacity
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Create Snapshot Procedures') AS script_name;

DELIMITER //
CREATE PROCEDURE capture_dba_lifecycle_snapshot()
BEGIN
  INSERT INTO dba_lifecycle_object_snap (object_schema, object_name, object_type, data_bytes, index_bytes, rows_estimate)
  SELECT table_schema, table_name, table_type, data_length, index_length, table_rows
  FROM information_schema.tables
  WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema');
END//
DELIMITER ;
