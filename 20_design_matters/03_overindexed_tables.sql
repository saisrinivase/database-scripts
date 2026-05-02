/*
Oracle DBA Script: Overindexed Tables
Purpose: Provide Oracle DBA diagnostics for overindexed tables.
Area: Design Matters
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

PROMPT Overindexed Tables

SELECT table_owner AS owner, table_name, COUNT(*) AS index_count,
       ROUND(SUM(NVL(s.bytes,0))/1024/1024,2) AS index_mb
FROM dba_indexes i
LEFT JOIN dba_segments s ON s.owner = i.owner AND s.segment_name = i.index_name
WHERE table_owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
GROUP BY table_owner, table_name
HAVING COUNT(*) >= 6
ORDER BY index_count DESC, index_mb DESC;
