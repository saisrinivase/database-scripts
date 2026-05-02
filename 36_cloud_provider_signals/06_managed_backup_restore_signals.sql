/*
Oracle DBA Script: Managed Backup Restore Signals
Purpose: Collect backup, FRA, and restore point evidence useful for managed Oracle services.
Area: Cloud Provider Signals
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only managed service backup/restore evidence.
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

PROMPT Managed Backup Restore Signals

SELECT 'RMAN_JOBS_7D' AS signal_name, COUNT(*) AS signal_value
FROM v$rman_backup_job_details
WHERE start_time >= SYSDATE - 7
UNION ALL
SELECT 'RMAN_FAILED_7D', COUNT(*)
FROM v$rman_backup_job_details
WHERE start_time >= SYSDATE - 7 AND status NOT LIKE 'COMPLETED%'
UNION ALL
SELECT 'RESTORE_POINTS', COUNT(*) FROM v$restore_point
UNION ALL
SELECT 'FRA_FILES', NVL(MAX(number_of_files),0) FROM v$recovery_file_dest;
