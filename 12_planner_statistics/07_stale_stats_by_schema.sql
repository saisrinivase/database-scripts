/*
Oracle DBA Script: Stale Stats By Schema
Purpose: Summarize stale/missing optimizer statistics by schema.
Area: Planner Statistics
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only optimizer stats inventory.
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

PROMPT Stale Stats By Schema

SELECT owner,
       COUNT(*) AS table_stats_rows,
       SUM(CASE WHEN stale_stats = 'YES' THEN 1 ELSE 0 END) AS stale_tables,
       SUM(CASE WHEN last_analyzed IS NULL THEN 1 ELSE 0 END) AS never_analyzed_tables,
       MIN(last_analyzed) AS oldest_analyzed,
       MAX(last_analyzed) AS newest_analyzed
FROM dba_tab_statistics
WHERE object_type = 'TABLE'
  AND owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
GROUP BY owner
ORDER BY stale_tables DESC, never_analyzed_tables DESC, owner;
