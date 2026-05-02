/*
Oracle DBA Script: Lobs Summary
Purpose: Provide Oracle DBA diagnostics for lobs summary.
Area: Lob Blob Storage
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

PROMPT Lobs Summary

SELECT l.owner, COUNT(*) AS lob_columns,
       SUM(CASE WHEN securefile = 'YES' THEN 1 ELSE 0 END) AS securefile_lobs,
       SUM(CASE WHEN securefile = 'NO' THEN 1 ELSE 0 END) AS basicfile_lobs,
       SUM(CASE WHEN compression <> 'NO' THEN 1 ELSE 0 END) AS compressed_lobs,
       SUM(CASE WHEN deduplication <> 'NO' THEN 1 ELSE 0 END) AS deduplicated_lobs
FROM dba_lobs l
WHERE l.owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
GROUP BY l.owner
ORDER BY lob_columns DESC;
