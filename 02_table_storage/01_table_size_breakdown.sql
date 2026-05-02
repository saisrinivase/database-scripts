/*
Oracle DBA Script: Table Size Breakdown
Purpose: Provide Oracle DBA diagnostics for table size breakdown.
Area: Table Storage
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

PROMPT Table Size Breakdown

SELECT t.owner, t.table_name, t.tablespace_name,
       ROUND(NVL(s.bytes,0)/1024/1024,2) AS segment_mb,
       t.num_rows, t.blocks, t.avg_row_len, t.partitioned,
       t.compression, t.logging, t.last_analyzed
FROM dba_tables t
LEFT JOIN (
    SELECT owner, segment_name, SUM(bytes) bytes
    FROM dba_segments
    WHERE segment_type LIKE 'TABLE%'
    GROUP BY owner, segment_name
) s ON s.owner = t.owner AND s.segment_name = t.table_name
WHERE t.owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
ORDER BY segment_mb DESC NULLS LAST;
