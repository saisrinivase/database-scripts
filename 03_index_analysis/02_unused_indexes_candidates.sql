/*
Oracle DBA Script: Unused Indexes Candidates
Purpose: Provide Oracle DBA diagnostics for unused indexes candidates.
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

PROMPT Unused Indexes Candidates

SELECT i.owner, i.index_name, i.table_owner, i.table_name, i.index_type, i.status,
       i.visibility, i.num_rows, i.leaf_blocks, i.clustering_factor,
       CASE WHEN i.num_rows > 0 THEN ROUND(i.clustering_factor / i.num_rows, 4) END AS clustering_ratio,
       i.last_analyzed
FROM dba_indexes i
WHERE i.owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
  AND i.index_type NOT LIKE 'LOB%'
  AND (i.visibility = 'INVISIBLE' OR i.status <> 'VALID' OR i.last_analyzed < SYSDATE - 30)
ORDER BY i.status, i.visibility, i.last_analyzed NULLS FIRST;
