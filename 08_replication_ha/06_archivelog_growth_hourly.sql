/*
Oracle DBA Script: Archivelog Growth Hourly
Purpose: Show hourly archived redo generation for burst analysis.
Area: Replication Ha
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only archived redo burst analysis.
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

PROMPT Archivelog Growth Hourly

DEFINE days_back = 7
SELECT TRUNC(first_time, 'HH24') AS archive_hour,
       thread#,
       COUNT(*) AS archived_logs,
       ROUND(SUM(blocks * block_size)/1024/1024/1024, 2) AS archived_gb,
       ROUND(AVG(blocks * block_size)/1024/1024, 2) AS avg_log_mb
FROM v$archived_log
WHERE first_time >= SYSDATE - &&days_back
  AND name IS NOT NULL
  AND archived = 'YES'
GROUP BY TRUNC(first_time, 'HH24'), thread#
ORDER BY archive_hour DESC, thread#;
