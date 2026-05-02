/*
Oracle DBA Script: Tablespace Growth Report
Purpose: Report growth from the local tablespace capacity snapshot table.
Area: Capacity Forecasting
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Requires running 09_capture_tablespace_usage_snapshot.sql over time.
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

PROMPT Tablespace Growth Report

SELECT tablespace_name,
       TRUNC(snap_time) AS snap_day,
       ROUND(MAX(used_bytes)/1024/1024/1024, 2) AS used_gb,
       ROUND(MAX(max_bytes)/1024/1024/1024, 2) AS max_gb,
       ROUND(MAX(used_percent), 2) AS used_pct,
       ROUND((MAX(used_bytes) - LAG(MAX(used_bytes)) OVER (PARTITION BY tablespace_name ORDER BY TRUNC(snap_time)))/1024/1024/1024, 2) AS daily_growth_gb
FROM dba_capacity_tablespace_snap
GROUP BY tablespace_name, TRUNC(snap_time)
ORDER BY tablespace_name, snap_day;
