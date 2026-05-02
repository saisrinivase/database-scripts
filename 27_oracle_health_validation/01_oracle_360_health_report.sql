/*
Oracle DBA Script: Oracle 360 Health Report
Purpose: Provide Oracle DBA diagnostics for oracle 360 health report.
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

PROMPT Oracle 360 Health Report

SELECT section_name, finding_count
FROM (
    SELECT 'Database and instance' section_name, COUNT(*) finding_count FROM v$database
    UNION ALL SELECT 'Invalid objects', COUNT(*) FROM dba_objects WHERE status <> 'VALID'
    UNION ALL SELECT 'Stale table statistics', COUNT(*) FROM dba_tab_statistics WHERE object_type = 'TABLE' AND stale_stats = 'YES'
    UNION ALL SELECT 'Disabled constraints', COUNT(*) FROM dba_constraints WHERE status <> 'ENABLED'
    UNION ALL SELECT 'Recent RMAN failures', COUNT(*) FROM v$rman_backup_job_details WHERE start_time >= SYSDATE - 7 AND status NOT LIKE 'COMPLETED%'
);
