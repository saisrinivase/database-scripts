/*
Oracle DBA Script: Index Maintenance Candidates
Purpose: Provide Oracle DBA diagnostics for index maintenance candidates.
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

PROMPT Index Maintenance Candidates

SELECT owner, index_name, table_owner, table_name, index_type, status, visibility,
       leaf_blocks, distinct_keys, clustering_factor, num_rows, last_analyzed,
       CASE
         WHEN status <> 'VALID' THEN 'REBUILD_OR_FIX_INVALID'
         WHEN visibility = 'INVISIBLE' THEN 'REVIEW_INVISIBLE_INDEX'
         WHEN last_analyzed < SYSDATE - 30 THEN 'GATHER_INDEX_STATS'
         WHEN num_rows > 0 AND clustering_factor > num_rows * 0.9 THEN 'REVIEW_CLUSTERING_FACTOR'
         ELSE 'REVIEW'
       END AS suggested_action
FROM dba_indexes
WHERE owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
ORDER BY suggested_action, owner, index_name;
