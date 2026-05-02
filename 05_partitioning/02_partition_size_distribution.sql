/*
Oracle DBA Script: Partition Size Distribution
Purpose: Provide Oracle DBA diagnostics for partition size distribution.
Area: Partitioning
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

PROMPT Partition Size Distribution

SELECT p.table_owner AS owner, p.table_name,
       COUNT(*) AS partition_count,
       ROUND(SUM(NVL(s.bytes,0))/1024/1024,2) AS total_partition_mb,
       ROUND(MIN(NVL(s.bytes,0))/1024/1024,2) AS min_partition_mb,
       ROUND(MAX(NVL(s.bytes,0))/1024/1024,2) AS max_partition_mb
FROM dba_tab_partitions p
LEFT JOIN dba_segments s ON s.owner = p.table_owner AND s.segment_name = p.table_name AND s.partition_name = p.partition_name
WHERE p.table_owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
GROUP BY p.table_owner, p.table_name
ORDER BY total_partition_mb DESC;
