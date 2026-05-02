/*
Oracle DBA Script: Capture Connection Snapshot
Purpose: Provide Oracle DBA diagnostics for capture connection snapshot.
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

PROMPT Capture Connection Snapshot

SELECT SYSTIMESTAMP AS snap_time, inst_id, username, service_name, status, COUNT(*) AS session_count
FROM gv$session
WHERE username IS NOT NULL
GROUP BY inst_id, username, service_name, status
ORDER BY session_count DESC;
