/*
Oracle DBA Script: FRA Usage By File Type
Purpose: Show fast recovery area quota, used space, reclaimable space, and file-type usage.
Area: Replication Ha
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only FRA pressure check using V$RECOVERY_FILE_DEST and V$RECOVERY_AREA_USAGE.
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

PROMPT FRA Usage By File Type

SELECT 'FRA_DEST' AS section_name,
       name AS file_type,
       ROUND(space_limit/1024/1024/1024, 2) AS limit_gb,
       ROUND(space_used/1024/1024/1024, 2) AS used_gb,
       ROUND(space_reclaimable/1024/1024/1024, 2) AS reclaimable_gb,
       number_of_files
FROM v$recovery_file_dest
UNION ALL
SELECT 'FRA_FILE_TYPE',
       file_type,
       NULL,
       ROUND(percent_space_used, 2),
       ROUND(percent_space_reclaimable, 2),
       number_of_files
FROM v$recovery_area_usage
ORDER BY section_name, used_gb DESC NULLS LAST;
