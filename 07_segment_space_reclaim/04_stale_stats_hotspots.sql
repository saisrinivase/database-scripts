/*
Oracle DBA Script: Stale Stats Hotspots
Purpose: Provide Oracle DBA diagnostics for stale stats hotspots.
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

PROMPT Stale Stats Hotspots

SELECT owner, table_name, stale_stats, num_rows, blocks, last_analyzed
FROM dba_tab_statistics
WHERE object_type = 'TABLE'
  AND owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
  AND (stale_stats = 'YES' OR last_analyzed IS NULL OR last_analyzed < SYSDATE - 30)
ORDER BY last_analyzed NULLS FIRST, num_rows DESC NULLS LAST;
