/*
Oracle DBA Script: Temp Undo Space Usage
Purpose: Show current temporary and undo space pressure.
Area: Database Size
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only current TEMP and UNDO pressure check.
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

PROMPT Temp Undo Space Usage

SELECT 'TEMP_USAGE' AS section_name,
       tablespace_name,
       ROUND(SUM(bytes_used)/1024/1024/1024, 2) AS used_gb,
       ROUND(SUM(bytes_free)/1024/1024/1024, 2) AS free_gb,
       ROUND(SUM(bytes_used)/NULLIF(SUM(bytes_used+bytes_free),0)*100, 2) AS used_pct
FROM v$temp_space_header
GROUP BY tablespace_name
UNION ALL
SELECT 'UNDO_USAGE',
       tablespace_name,
       ROUND(SUM(bytes)/1024/1024/1024, 2),
       NULL,
       NULL
FROM dba_undo_extents
WHERE status IN ('ACTIVE','UNEXPIRED')
GROUP BY tablespace_name
ORDER BY section_name, used_pct DESC NULLS LAST;
