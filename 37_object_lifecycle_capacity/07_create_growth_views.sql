/*
Oracle DBA Script: Create Growth Views
Purpose: Provide Oracle DBA diagnostics for create growth views.
Area: Object Lifecycle Capacity
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

PROMPT Create Growth Views

CREATE OR REPLACE VIEW dba_object_growth_v AS
SELECT owner, object_name, object_type, TRUNC(snap_time) snap_day, MAX(bytes) max_bytes
FROM dba_lifecycle_object_snap
GROUP BY owner, object_name, object_type, TRUNC(snap_time);
