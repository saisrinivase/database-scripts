/*
Oracle DBA Script: Capture Redo Snapshot
Purpose: Provide Oracle DBA diagnostics for capture redo snapshot.
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

PROMPT Capture Redo Snapshot

SELECT SYSTIMESTAMP AS snap_time, TRUNC(first_time, 'HH24') AS hour_bucket,
       COUNT(*) AS archived_logs, SUM(blocks * block_size) AS redo_bytes
FROM v$archived_log
WHERE first_time >= SYSDATE - 1
GROUP BY TRUNC(first_time, 'HH24')
ORDER BY hour_bucket DESC;
