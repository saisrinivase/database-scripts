/*
Oracle DBA Script: Databases Size
Purpose: Provide Oracle DBA diagnostics for databases size.
Area: Database Size
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

PROMPT Databases Size

SELECT
    d.name AS database_name,
    ROUND((datafiles.bytes + NVL(tempfiles.bytes,0) + NVL(redologs.bytes,0)) / 1024 / 1024 / 1024, 2) AS allocated_gb,
    ROUND(datafiles.bytes / 1024 / 1024 / 1024, 2) AS datafile_gb,
    ROUND(NVL(tempfiles.bytes,0) / 1024 / 1024 / 1024, 2) AS tempfile_gb,
    ROUND(NVL(redologs.bytes,0) / 1024 / 1024 / 1024, 2) AS redo_gb
FROM v$database d
CROSS JOIN (SELECT SUM(bytes) bytes FROM dba_data_files) datafiles
CROSS JOIN (SELECT SUM(bytes) bytes FROM dba_temp_files) tempfiles
CROSS JOIN (SELECT SUM(bytes) bytes FROM v$log) redologs;
