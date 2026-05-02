/*
Oracle DBA Script: Database Growth Report
Purpose: Provide Oracle DBA diagnostics for database growth report.
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

PROMPT Database Growth Report

SELECT database_name, TRUNC(snap_time) AS snap_day,
       ROUND(MAX(allocated_bytes)/1024/1024/1024,2) AS allocated_gb,
       ROUND(MAX(segment_bytes)/1024/1024/1024,2) AS segment_gb
FROM dba_capacity_database_snap
GROUP BY database_name, TRUNC(snap_time)
ORDER BY snap_day DESC;
