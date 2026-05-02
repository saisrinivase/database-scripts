/*
Oracle DBA Script: Capture Database Size Snapshot
Purpose: Provide Oracle DBA diagnostics for capture database size snapshot.
Area: Capacity Forecasting
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Review findings before taking action. Some performance history views require the Oracle Diagnostics Pack license.
*/
SET LINESIZE 220
SET PAGESIZE 200
SET TRIMSPOOL ON
SET TAB OFF
COLUMN owner FORMAT A28
COLUMN object_name FORMAT A38
COLUMN segment_name FORMAT A38
COLUMN table_name FORMAT A38
COLUMN index_name FORMAT A38
COLUMN sql_id FORMAT A14
COLUMN event FORMAT A48
COLUMN parameter_name FORMAT A45
COLUMN value FORMAT A45

PROMPT Capture Database Size Snapshot

INSERT INTO dba_capacity_database_snap (database_name, allocated_bytes, segment_bytes, tempfile_bytes, redo_bytes)
SELECT d.name,
       (SELECT SUM(bytes) FROM dba_data_files),
       (SELECT SUM(bytes) FROM dba_segments),
       (SELECT SUM(bytes) FROM dba_temp_files),
       (SELECT SUM(bytes) FROM v$log)
FROM v$database d;
COMMIT;
