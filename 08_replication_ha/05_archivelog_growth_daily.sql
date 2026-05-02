/*
Oracle DBA Script: Archivelog Growth Daily
Purpose: Show daily archived redo generation by thread and destination.
Area: Replication Ha
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only archived redo growth from control-file metadata; duplicate archive destinations are shown separately.
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

PROMPT Archivelog Growth Daily

DEFINE days_back = 30
SELECT TRUNC(first_time) AS archive_day,
       thread#,
       dest_id,
       COUNT(*) AS archived_logs,
       ROUND(SUM(blocks * block_size)/1024/1024/1024, 2) AS archived_gb,
       MIN(sequence#) AS first_sequence,
       MAX(sequence#) AS last_sequence
FROM v$archived_log
WHERE first_time >= SYSDATE - &&days_back
  AND name IS NOT NULL
  AND archived = 'YES'
GROUP BY TRUNC(first_time), thread#, dest_id
ORDER BY archive_day DESC, thread#, dest_id;
