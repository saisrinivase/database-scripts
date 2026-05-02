/*
Oracle DBA Script: Monthly Capacity Report
Purpose: Provide Oracle DBA diagnostics for monthly capacity report.
Area: Object Lifecycle Capacity
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

PROMPT Monthly Capacity Report

SELECT owner, object_type, snap_day, ROUND(SUM(max_bytes)/1024/1024,2) AS total_mb
FROM dba_object_growth_v
GROUP BY owner, object_type, snap_day
ORDER BY snap_day DESC, total_mb DESC;
