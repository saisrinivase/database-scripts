/*
Oracle DBA Script: Data Guard Lag Dashboard
Purpose: Show Data Guard transport/apply lag and archive destination status.
Area: Replication Ha
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only Data Guard status check. V$DATAGUARD_STATS returns rows primarily on standby databases.
*/
SET LINESIZE 220
SET PAGESIZE 200
SET TRIMSPOOL ON
SET TAB OFF
COLUMN owner FORMAT A28
COLUMN object_name FORMAT A38
COLUMN tablespace_name FORMAT A30
COLUMN sql_id FORMAT A14
COLUMN event FORMAT A48
COLUMN metric_name FORMAT A48
COLUMN parameter_name FORMAT A45
COLUMN value FORMAT A45

PROMPT Data Guard Lag Dashboard

SELECT 'DATAGUARD_STATS' AS section_name,
       name AS metric_name,
       value,
       unit,
       time_computed,
       datum_time,
       NULL AS destination,
       NULL AS error
FROM v$dataguard_stats
UNION ALL
SELECT 'ARCHIVE_DEST_STATUS',
       'DEST_' || dest_id || '_' || status,
       database_mode || '/' || recovery_mode,
       protection_mode,
       NULL,
       NULL,
       destination,
       error
FROM v$archive_dest_status
WHERE dest_id > 0
ORDER BY section_name, metric_name;
