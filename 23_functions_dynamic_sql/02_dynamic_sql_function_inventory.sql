/*
Oracle DBA Script: Dynamic Sql Function Inventory
Purpose: Provide Oracle DBA diagnostics for dynamic sql function inventory.
Area: Functions Dynamic Sql
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

PROMPT Dynamic Sql Function Inventory

SELECT owner, name, type, line, SUBSTR(text,1,200) AS source_text
FROM dba_source
WHERE owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
  AND REGEXP_LIKE(UPPER(text), 'EXECUTE IMMEDIATE|DBMS_SQL')
ORDER BY owner, name, type, line;
