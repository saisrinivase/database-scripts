/*
Oracle DBA Script: Enterprise Takeover Gate
Purpose: Provide Oracle DBA diagnostics for enterprise takeover gate.
Area: Oracle Health Validation
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

PROMPT Enterprise Takeover Gate

SELECT gate_name, status, finding_count
FROM (
    SELECT 'INVALID_OBJECTS' gate_name, CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'REVIEW' END status, COUNT(*) finding_count FROM dba_objects WHERE status <> 'VALID'
    UNION ALL SELECT 'FAILED_BACKUPS_7D', CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'REVIEW' END, COUNT(*) FROM v$rman_backup_job_details WHERE start_time >= SYSDATE - 7 AND status NOT LIKE 'COMPLETED%'
    UNION ALL SELECT 'BLOCK_CORRUPTION', CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'REVIEW' END, COUNT(*) FROM v$database_block_corruption
    UNION ALL SELECT 'ARCHIVE_DEST_ERRORS', CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'REVIEW' END, COUNT(*) FROM v$archive_dest_status WHERE error IS NOT NULL
);
