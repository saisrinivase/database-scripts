/*
Oracle DBA Script: Dr Rto Rpo Replication Evidence
Purpose: Provide Oracle DBA diagnostics for dr rto rpo replication evidence.
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

PROMPT Dr Rto Rpo Replication Evidence

SELECT input_type, status, start_time, end_time, time_taken_display,
       ROUND(input_bytes/1024/1024/1024,2) AS input_gb,
       ROUND(output_bytes/1024/1024/1024,2) AS output_gb
FROM v$rman_backup_job_details
WHERE start_time >= SYSDATE - 30
ORDER BY start_time DESC;
