/*
MySQL DBA Script: Create Lifecycle Repository
Purpose: Provide MySQL DBA diagnostics for create lifecycle repository.
Area: Object Lifecycle Capacity
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Create Lifecycle Repository') AS script_name;

CREATE TABLE IF NOT EXISTS dba_lifecycle_object_snap (
  snap_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  object_schema VARCHAR(64),
  object_name VARCHAR(64),
  object_type VARCHAR(32),
  data_bytes BIGINT,
  index_bytes BIGINT,
  rows_estimate BIGINT,
  PRIMARY KEY (snap_time, object_schema, object_name, object_type)
);
