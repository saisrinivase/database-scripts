/*
Oracle DBA Script: Table Space Reclaim Estimate
Purpose: Provide Oracle DBA diagnostics for table space reclaim estimate.
Area: Segment Space Reclaim
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

PROMPT Table Space Reclaim Estimate

SELECT t.owner, t.table_name, ROUND(NVL(s.bytes,0)/1024/1024,2) AS segment_mb,
       t.num_rows, t.blocks, t.empty_blocks, t.avg_space, t.chain_cnt, t.last_analyzed,
       CASE
         WHEN t.last_analyzed IS NULL THEN 'GATHER_STATS'
         WHEN t.chain_cnt > 0 THEN 'REVIEW_ROW_CHAINING'
         WHEN NVL(s.bytes,0) > 1024*1024*1024 AND NVL(t.num_rows,0) = 0 THEN 'REVIEW_UNUSED_SEGMENT'
         ELSE 'REVIEW_SEGMENT_ADVISOR'
       END AS suggested_check
FROM dba_tables t
LEFT JOIN dba_segments s ON s.owner = t.owner AND s.segment_name = t.table_name
WHERE t.owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
ORDER BY segment_mb DESC NULLS LAST;
