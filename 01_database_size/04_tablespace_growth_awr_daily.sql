/*
Oracle DBA Script: Tablespace Growth AWR Daily
Purpose: Show daily allocated, used, and daily growth by tablespace from AWR history.
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

PROMPT Tablespace Growth AWR Daily

DEFINE days_back = 30
WITH snap_day AS (
    SELECT dbid, snap_id, TRUNC(MIN(begin_interval_time)) AS snap_date
    FROM dba_hist_snapshot
    WHERE begin_interval_time >= SYSDATE - &&days_back
    GROUP BY dbid, snap_id
), daily AS (
    SELECT sd.snap_date,
           ts.tsname AS tablespace_name,
           MAX(ROUND(tsu.tablespace_size * dt.block_size / 1024 / 1024 / 1024, 2)) AS allocated_gb,
           MAX(ROUND(tsu.tablespace_usedsize * dt.block_size / 1024 / 1024 / 1024, 2)) AS used_gb,
           MAX(ROUND(tsu.tablespace_maxsize * dt.block_size / 1024 / 1024 / 1024, 2)) AS max_gb
    FROM dba_hist_tbspc_space_usage tsu
    JOIN dba_hist_tablespace_stat ts ON ts.dbid = tsu.dbid AND ts.ts# = tsu.tablespace_id
    JOIN snap_day sd ON sd.dbid = tsu.dbid AND sd.snap_id = tsu.snap_id
    JOIN dba_tablespaces dt ON dt.tablespace_name = ts.tsname
    GROUP BY sd.snap_date, ts.tsname
)
SELECT snap_date,
       tablespace_name,
       allocated_gb,
       used_gb,
       max_gb,
       ROUND(used_gb - LAG(used_gb) OVER (PARTITION BY tablespace_name ORDER BY snap_date), 2) AS used_growth_gb,
       ROUND(allocated_gb - LAG(allocated_gb) OVER (PARTITION BY tablespace_name ORDER BY snap_date), 2) AS allocated_growth_gb
FROM daily
ORDER BY tablespace_name, snap_date;
