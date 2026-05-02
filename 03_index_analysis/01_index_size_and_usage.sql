/*
Oracle DBA Script: Index Size And Usage
Purpose: Provide Oracle DBA diagnostics for index size and usage.
Area: Index Analysis
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

PROMPT Index Size And Usage

SELECT i.owner, i.index_name, i.table_owner, i.table_name, i.tablespace_name,
       i.index_type, i.uniqueness, i.status, i.visibility,
       ROUND(NVL(s.bytes,0)/1024/1024,2) AS segment_mb,
       i.leaf_blocks, i.distinct_keys, i.clustering_factor, i.num_rows, i.last_analyzed
FROM dba_indexes i
LEFT JOIN dba_segments s ON s.owner = i.owner AND s.segment_name = i.index_name
WHERE i.owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
ORDER BY segment_mb DESC NULLS LAST;
