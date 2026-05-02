/*
Oracle DBA Script: Segment Growth Report AWR
Purpose: Summarize recent AWR segment growth by owner and object type.
Area: Capacity Forecasting
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

PROMPT Segment Growth Report AWR

DEFINE days_back = 30
SELECT * FROM (
    SELECT o.owner,
           o.object_type,
           ROUND(SUM(h.space_used_delta)/1024/1024/1024, 2) AS used_growth_gb,
           ROUND(SUM(h.space_allocated_delta)/1024/1024/1024, 2) AS allocated_growth_gb,
           SUM(h.logical_reads_delta) AS logical_reads,
           SUM(h.physical_reads_delta) AS physical_reads
    FROM dba_hist_seg_stat h
    JOIN dba_hist_snapshot s ON s.dbid = h.dbid AND s.snap_id = h.snap_id AND s.instance_number = h.instance_number
    LEFT JOIN dba_objects o ON o.object_id = h.obj#
    WHERE s.begin_interval_time >= SYSDATE - &&days_back
      AND NVL(o.owner, 'UNKNOWN') NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
    GROUP BY o.owner, o.object_type
    ORDER BY ABS(SUM(h.space_used_delta)) DESC
) WHERE ROWNUM <= 100;
