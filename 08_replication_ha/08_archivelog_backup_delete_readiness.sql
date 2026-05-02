/*
Oracle DBA Script: Archivelog Backup Delete Readiness
Purpose: Find archived logs that are old, not backed up, or not applied to standby destinations.
Area: Replication Ha
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only retention evidence. Apply local RMAN retention/delete policy before deleting archive logs.
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

PROMPT Archivelog Backup Delete Readiness

DEFINE days_back = 14
SELECT thread#,
       sequence#,
       dest_id,
       first_time,
       next_time,
       deleted,
       applied,
       backup_count,
       standby_dest,
       ROUND(blocks * block_size / 1024 / 1024, 2) AS size_mb,
       name,
       CASE
         WHEN deleted = 'YES' THEN 'ALREADY_DELETED'
         WHEN backup_count = 0 THEN 'NOT_BACKED_UP'
         WHEN standby_dest = 'YES' AND applied <> 'YES' THEN 'NOT_APPLIED_TO_STANDBY'
         WHEN first_time < SYSDATE - &&days_back THEN 'REVIEW_RETENTION_DELETE_POLICY'
         ELSE 'KEEP_MONITORING'
       END AS readiness_status
FROM v$archived_log
WHERE first_time >= SYSDATE - &&days_back * 3
  AND name IS NOT NULL
ORDER BY first_time DESC, thread#, sequence#, dest_id;
