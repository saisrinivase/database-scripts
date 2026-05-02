/*
Oracle DBA Script: Create Action Advisory Views
Purpose: Provide Oracle DBA diagnostics for create action advisory views.
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

PROMPT Create Action Advisory Views

CREATE OR REPLACE VIEW dba_lifecycle_action_advice_v AS
SELECT owner, object_name, object_type, status,
       CASE WHEN status <> 'VALID' THEN 'COMPILE_OR_REPAIR'
            WHEN bytes IS NULL THEN 'NO_SEGMENT_OR_METADATA_ONLY'
            ELSE 'MONITOR'
       END AS recommended_action
FROM dba_lifecycle_object_snap
WHERE snap_time = (SELECT MAX(snap_time) FROM dba_lifecycle_object_snap);
