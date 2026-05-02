/*
Oracle DBA Script: Database Io Profile
Purpose: Provide Oracle DBA diagnostics for database io profile.
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

PROMPT Database Io Profile

SELECT df.tablespace_name, df.file_name,
       fs.phyrds, fs.phywrts, fs.readtim, fs.writetim,
       ROUND(df.bytes/1024/1024,2) AS file_mb
FROM v$filestat fs
JOIN dba_data_files df ON df.file_id = fs.file#
ORDER BY (fs.phyrds + fs.phywrts) DESC;
