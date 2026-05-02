/*
Oracle DBA Script: Archivelog Gap And Lag
Purpose: Provide Oracle DBA diagnostics for archivelog gap and lag.
Area: Backup Restore Pitr Dr
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

PROMPT Archivelog Gap And Lag

SELECT TRUNC(first_time, 'HH24') AS hour_bucket,
       COUNT(*) AS archived_logs,
       ROUND(SUM(blocks * block_size)/1024/1024,2) AS redo_mb
FROM v$archived_log
WHERE first_time >= SYSDATE - 7
GROUP BY TRUNC(first_time, 'HH24')
ORDER BY hour_bucket DESC;
