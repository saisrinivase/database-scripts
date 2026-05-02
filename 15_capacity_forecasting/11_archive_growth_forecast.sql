/*
Oracle DBA Script: Archive Growth Forecast
Purpose: Forecast FRA pressure from recent archive generation.
Area: Capacity Forecasting
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only forecast based only on archived redo generation and current FRA metadata.
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

PROMPT Archive Growth Forecast

DEFINE days_back = 14
WITH daily_arch AS (
    SELECT TRUNC(first_time) AS snap_day,
           SUM(blocks * block_size) AS archived_bytes
    FROM v$archived_log
    WHERE first_time >= SYSDATE - &&days_back
      AND name IS NOT NULL
      AND archived = 'YES'
      AND dest_id = 1
    GROUP BY TRUNC(first_time)
), avg_arch AS (
    SELECT AVG(archived_bytes) AS avg_daily_archived_bytes FROM daily_arch
), fra AS (
    SELECT space_limit, space_used, space_reclaimable FROM v$recovery_file_dest
)
SELECT ROUND(f.space_limit/1024/1024/1024, 2) AS fra_limit_gb,
       ROUND(f.space_used/1024/1024/1024, 2) AS fra_used_gb,
       ROUND(f.space_reclaimable/1024/1024/1024, 2) AS fra_reclaimable_gb,
       ROUND(a.avg_daily_archived_bytes/1024/1024/1024, 2) AS avg_daily_archive_gb,
       ROUND((f.space_limit - f.space_used + f.space_reclaimable) / NULLIF(a.avg_daily_archived_bytes,0), 1) AS estimated_days_to_pressure
FROM fra f CROSS JOIN avg_arch a;
