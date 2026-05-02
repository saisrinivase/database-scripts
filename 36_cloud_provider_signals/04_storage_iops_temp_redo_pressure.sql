/*
Oracle DBA Script: Storage Iops Temp Redo Pressure
Purpose: Provide Oracle DBA diagnostics for storage iops temp redo pressure.
Area: Cloud Provider Signals
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

PROMPT Storage Iops Temp Redo Pressure

SELECT filetype_name,
       small_read_reqs, small_write_reqs, large_read_reqs, large_write_reqs,
       small_read_megabytes, small_write_megabytes, large_read_megabytes, large_write_megabytes
FROM v$iostat_file
ORDER BY filetype_name;
