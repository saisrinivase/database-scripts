/*
Oracle DBA Script: RMAN Backup Job History
Purpose: Show recent RMAN job status, duration, throughput, and sizes.
Area: Backup Restore Pitr Dr
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only RMAN repository/control-file backup job evidence.
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

PROMPT RMAN Backup Job History

DEFINE days_back = 30
SELECT session_key,
       input_type,
       status,
       start_time,
       end_time,
       time_taken_display,
       ROUND(input_bytes/1024/1024/1024, 2) AS input_gb,
       ROUND(output_bytes/1024/1024/1024, 2) AS output_gb,
       input_bytes_per_sec_display,
       output_bytes_per_sec_display
FROM v$rman_backup_job_details
WHERE start_time >= SYSDATE - &&days_back
ORDER BY start_time DESC;
