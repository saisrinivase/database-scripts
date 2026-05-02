/*
Oracle DBA Script: Unrecoverable Operations
Purpose: Identify datafiles with unrecoverable changes requiring backup attention.
Area: Backup Restore Pitr Dr
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only unrecoverable operation evidence. Review backup posture after NOLOGGING operations.
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

PROMPT Unrecoverable Operations

SELECT df.tablespace_name,
       df.file_id,
       df.file_name,
       df.unrecoverable_change#,
       df.unrecoverable_time,
       ROUND(df.bytes/1024/1024/1024, 2) AS file_gb
FROM v$datafile df
WHERE df.unrecoverable_change# > 0
ORDER BY df.unrecoverable_time DESC NULLS LAST;
