/*
Oracle DBA Script: Wide Tables Profile
Purpose: Provide Oracle DBA diagnostics for wide tables profile.
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

PROMPT Wide Tables Profile

SELECT owner, table_name, COUNT(*) AS column_count,
       SUM(CASE WHEN nullable = 'Y' THEN 1 ELSE 0 END) AS nullable_columns
FROM dba_tab_columns
WHERE owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
GROUP BY owner, table_name
HAVING COUNT(*) >= 50
ORDER BY column_count DESC;
