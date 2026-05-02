/*
Oracle DBA Script: Current Database Size Breakdown
Purpose: Provide Oracle DBA diagnostics for current database size breakdown.
Area: Database Size
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

PROMPT Current Database Size Breakdown

SELECT component, ROUND(bytes / 1024 / 1024 / 1024, 2) AS gb
FROM (
    SELECT 'DATAFILES' component, SUM(bytes) bytes FROM dba_data_files
    UNION ALL SELECT 'TEMPFILES', SUM(bytes) FROM dba_temp_files
    UNION ALL SELECT 'ONLINE_REDO_LOGS', SUM(bytes) FROM v$log
    UNION ALL SELECT 'CONTROL_FILES_ESTIMATE', COUNT(*) * 1024 * 1024 FROM v$controlfile
    UNION ALL SELECT 'SEGMENTS_ALLOCATED', SUM(bytes) FROM dba_segments
)
ORDER BY gb DESC;
