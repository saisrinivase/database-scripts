/*
MySQL DBA Script: Create Capacity Repository
Purpose: Provide MySQL DBA diagnostics for create capacity repository.
Area: Capacity Forecasting
Usage: Run with the mysql client or MySQL Shell in SQL mode as a user with privileges to read information_schema, performance_schema, sys, and mysql metadata where referenced.
Notes: Review findings before taking action. Some scripts require performance_schema consumers/instruments to be enabled.
*/
/* MySQL client settings: run with mysql, MySQL Shell SQL mode, or a compatible client. */
SELECT CONCAT('Running: Create Capacity Repository') AS script_name;

CREATE TABLE IF NOT EXISTS dba_capacity_schema_snap (
  snap_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  schema_name VARCHAR(64) NOT NULL,
  data_bytes BIGINT,
  index_bytes BIGINT,
  free_bytes BIGINT,
  PRIMARY KEY (snap_time, schema_name)
);
CREATE TABLE IF NOT EXISTS dba_capacity_table_snap (
  snap_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  table_schema VARCHAR(64) NOT NULL,
  table_name VARCHAR(64) NOT NULL,
  data_bytes BIGINT,
  index_bytes BIGINT,
  free_bytes BIGINT,
  table_rows BIGINT,
  PRIMARY KEY (snap_time, table_schema, table_name)
);
