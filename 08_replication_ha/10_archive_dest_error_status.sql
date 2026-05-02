/*
Oracle DBA Script: Archive Dest Error Status
Purpose: List archive destinations with errors, gaps, or unavailable status.
Area: Replication Ha
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only archive destination status check.
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

PROMPT Archive Dest Error Status

SELECT dest_id,
       status,
       type,
       destination,
       archived_thread#,
       archived_seq#,
       applied_thread#,
       applied_seq#,
       db_unique_name,
       synchronization_status,
       synchronized,
       gap_status,
       error,
       CASE
         WHEN error IS NOT NULL THEN 'ERROR'
         WHEN status NOT IN ('VALID','INACTIVE') THEN 'REVIEW_STATUS'
         WHEN NVL(archived_seq#,0) - NVL(applied_seq#, archived_seq#) > 10 THEN 'APPLY_GAP_REVIEW'
         ELSE 'OK_OR_INACTIVE'
       END AS status_advice
FROM v$archive_dest_status
WHERE dest_id > 0
ORDER BY status_advice, dest_id;
