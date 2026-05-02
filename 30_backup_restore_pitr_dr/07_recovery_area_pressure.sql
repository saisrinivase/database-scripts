/*
Oracle DBA Script: Recovery Area Pressure
Purpose: Summarize FRA pressure and reclaimable bytes.
Area: Backup Restore Pitr Dr
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only FRA pressure check.
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

PROMPT Recovery Area Pressure

SELECT r.name,
       ROUND(r.space_limit/1024/1024/1024, 2) AS limit_gb,
       ROUND(r.space_used/1024/1024/1024, 2) AS used_gb,
       ROUND(r.space_reclaimable/1024/1024/1024, 2) AS reclaimable_gb,
       ROUND((r.space_used-r.space_reclaimable)/NULLIF(r.space_limit,0)*100, 2) AS non_reclaimable_used_pct,
       r.number_of_files
FROM v$recovery_file_dest r;

SELECT file_type,
       percent_space_used,
       percent_space_reclaimable,
       number_of_files
FROM v$recovery_area_usage
ORDER BY percent_space_used DESC;
