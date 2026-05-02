/*
Oracle DBA Script: Datafile Autoextend Headroom
Purpose: List datafile allocation, autoextend settings, increment size, and remaining headroom.
Area: Database Size
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only current datafile/tempfile headroom check; encrypted/offline files may need wallet/tablespace access.
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

PROMPT Datafile Autoextend Headroom

SELECT tablespace_name,
       file_id,
       file_name,
       status,
       online_status,
       autoextensible,
       ROUND(bytes/1024/1024/1024, 2) AS current_gb,
       ROUND(CASE WHEN autoextensible = 'YES' THEN maxbytes ELSE bytes END /1024/1024/1024, 2) AS max_or_fixed_gb,
       ROUND((CASE WHEN autoextensible = 'YES' THEN maxbytes ELSE bytes END - bytes)/1024/1024/1024, 2) AS headroom_gb,
       ROUND(increment_by * (SELECT TO_NUMBER(value) FROM v$parameter WHERE name='db_block_size') /1024/1024, 2) AS next_increment_mb
FROM dba_data_files
UNION ALL
SELECT tablespace_name,
       file_id,
       file_name,
       status,
       'TEMP' AS online_status,
       autoextensible,
       ROUND(bytes/1024/1024/1024, 2),
       ROUND(CASE WHEN autoextensible = 'YES' THEN maxbytes ELSE bytes END /1024/1024/1024, 2),
       ROUND((CASE WHEN autoextensible = 'YES' THEN maxbytes ELSE bytes END - bytes)/1024/1024/1024, 2),
       ROUND(increment_by * (SELECT TO_NUMBER(value) FROM v$parameter WHERE name='db_block_size') /1024/1024, 2)
FROM dba_temp_files
ORDER BY tablespace_name, file_id;
