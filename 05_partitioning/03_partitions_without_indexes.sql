/*
Oracle DBA Script: Partitions Without Indexes
Purpose: Provide Oracle DBA diagnostics for partitions without indexes.
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

PROMPT Partitions Without Indexes

SELECT pt.owner, pt.table_name, pt.partitioning_type, pt.subpartitioning_type,
       COUNT(DISTINCT ip.index_name) AS local_index_count
FROM dba_part_tables pt
LEFT JOIN dba_indexes i ON i.table_owner = pt.owner AND i.table_name = pt.table_name AND i.partitioned = 'YES'
LEFT JOIN dba_ind_partitions ip ON ip.index_owner = i.owner AND ip.index_name = i.index_name
WHERE pt.owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
GROUP BY pt.owner, pt.table_name, pt.partitioning_type, pt.subpartitioning_type
HAVING COUNT(DISTINCT ip.index_name) = 0
ORDER BY pt.owner, pt.table_name;
