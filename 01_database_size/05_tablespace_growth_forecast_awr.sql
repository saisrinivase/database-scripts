/*
Oracle DBA Script: Tablespace Growth Forecast AWR
Purpose: Estimate days-to-full using current usage and recent AWR daily growth.
Area: Database Size
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Review findings before taking action. AWR/ASH scripts require appropriate licensing and catalog privileges.
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

PROMPT Tablespace Growth Forecast AWR

DEFINE days_back = 30
WITH block_size AS (
    SELECT TO_NUMBER(value) AS bytes_per_block FROM v$parameter WHERE name = 'db_block_size'
), current_usage AS (
    SELECT m.tablespace_name,
           ROUND(m.used_space * b.bytes_per_block / 1024 / 1024 / 1024, 2) AS used_gb,
           ROUND(m.tablespace_size * b.bytes_per_block / 1024 / 1024 / 1024, 2) AS max_gb,
           ROUND((m.tablespace_size - m.used_space) * b.bytes_per_block / 1024 / 1024 / 1024, 2) AS free_to_max_gb,
           ROUND(m.used_percent, 2) AS used_pct
    FROM dba_tablespace_usage_metrics m CROSS JOIN block_size b
), snap_day AS (
    SELECT dbid, snap_id, TRUNC(MIN(begin_interval_time)) AS snap_date
    FROM dba_hist_snapshot
    WHERE begin_interval_time >= SYSDATE - &&days_back
    GROUP BY dbid, snap_id
), daily AS (
    SELECT sd.snap_date,
           ts.tsname AS tablespace_name,
           MAX(tsu.tablespace_usedsize * dt.block_size) AS used_bytes
    FROM dba_hist_tbspc_space_usage tsu
    JOIN dba_hist_tablespace_stat ts ON ts.dbid = tsu.dbid AND ts.ts# = tsu.tablespace_id
    JOIN snap_day sd ON sd.dbid = tsu.dbid AND sd.snap_id = tsu.snap_id
    JOIN dba_tablespaces dt ON dt.tablespace_name = ts.tsname
    GROUP BY sd.snap_date, ts.tsname
), growth AS (
    SELECT tablespace_name,
           ROUND((MAX(used_bytes) - MIN(used_bytes)) / 1024 / 1024 / 1024 / NULLIF(MAX(snap_date) - MIN(snap_date), 0), 3) AS avg_daily_growth_gb
    FROM daily
    GROUP BY tablespace_name
)
SELECT c.tablespace_name,
       c.used_gb,
       c.max_gb,
       c.free_to_max_gb,
       c.used_pct,
       NVL(g.avg_daily_growth_gb, 0) AS avg_daily_growth_gb,
       CASE WHEN NVL(g.avg_daily_growth_gb, 0) > 0 THEN ROUND(c.free_to_max_gb / g.avg_daily_growth_gb, 1) END AS days_to_full,
       CASE
         WHEN c.used_pct >= 90 THEN 'CRITICAL_CURRENT_USAGE'
         WHEN NVL(g.avg_daily_growth_gb, 0) > 0 AND c.free_to_max_gb / g.avg_daily_growth_gb <= 14 THEN 'CRITICAL_FORECAST'
         WHEN NVL(g.avg_daily_growth_gb, 0) > 0 AND c.free_to_max_gb / g.avg_daily_growth_gb <= 30 THEN 'WARNING_FORECAST'
         ELSE 'OK_OR_STABLE'
       END AS capacity_status
FROM current_usage c
LEFT JOIN growth g ON g.tablespace_name = c.tablespace_name
ORDER BY capacity_status, days_to_full NULLS LAST, c.used_pct DESC;
