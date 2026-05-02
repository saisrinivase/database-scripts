/*
Oracle DBA Script: Temp File Usage By Database
Purpose: Provide Oracle DBA diagnostics for temp file usage by database.
Area: Io Redo Checkpoints
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

PROMPT Temp File Usage By Database

SELECT tablespace_name,
       ROUND(SUM(bytes_used)/1024/1024,2) AS used_mb,
       ROUND(SUM(bytes_free)/1024/1024,2) AS free_mb,
       ROUND(SUM(bytes_used)/NULLIF(SUM(bytes_used + bytes_free),0)*100,2) AS used_pct
FROM v$temp_space_header
GROUP BY tablespace_name
ORDER BY used_pct DESC;
