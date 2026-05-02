/*
Oracle DBA Script: Top Segment Growth AWR
Purpose: Identify top segment growth and shrink events from AWR segment statistics.
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

PROMPT Top Segment Growth AWR

DEFINE days_back = 30
WITH seg_growth AS (
    SELECT h.obj#,
           h.dataobj#,
           SUM(h.space_used_delta) AS used_growth_bytes,
           SUM(h.space_allocated_delta) AS allocated_growth_bytes,
           SUM(h.db_block_changes_delta) AS db_block_changes,
           SUM(h.physical_reads_delta) AS physical_reads,
           SUM(h.logical_reads_delta) AS logical_reads
    FROM dba_hist_seg_stat h
    JOIN dba_hist_snapshot s ON s.dbid = h.dbid AND s.snap_id = h.snap_id AND s.instance_number = h.instance_number
    WHERE s.begin_interval_time >= SYSDATE - &&days_back
    GROUP BY h.obj#, h.dataobj#
)
SELECT * FROM (
    SELECT o.owner,
           o.object_name,
           o.subobject_name,
           o.object_type,
           ROUND(g.used_growth_bytes/1024/1024/1024, 2) AS used_growth_gb,
           ROUND(g.allocated_growth_bytes/1024/1024/1024, 2) AS allocated_growth_gb,
           g.db_block_changes,
           g.physical_reads,
           g.logical_reads
    FROM seg_growth g
    LEFT JOIN dba_objects o ON o.object_id = g.obj# AND NVL(o.data_object_id, o.object_id) = NVL(g.dataobj#, NVL(o.data_object_id, o.object_id))
    WHERE NVL(o.owner, 'UNKNOWN') NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
    ORDER BY ABS(g.used_growth_bytes) DESC NULLS LAST
) WHERE ROWNUM <= 100;
