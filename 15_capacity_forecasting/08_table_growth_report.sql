/*
Oracle DBA Script: Table Growth Report
Purpose: Provide Oracle DBA diagnostics for table growth report.
Area: Capacity Forecasting
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

PROMPT Table Growth Report

SELECT owner, segment_name, segment_type, TRUNC(snap_time) AS snap_day,
       ROUND(MAX(bytes)/1024/1024,2) AS max_mb
FROM dba_capacity_segment_snap
GROUP BY owner, segment_name, segment_type, TRUNC(snap_time)
ORDER BY max_mb DESC;
