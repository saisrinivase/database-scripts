/*
Oracle DBA Script: Domain Text Spatial Index Inventory
Purpose: Provide Oracle DBA diagnostics for domain text spatial index inventory.
Area: Complex Filter Search
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

PROMPT Domain Text Spatial Index Inventory

SELECT owner, index_name, table_owner, table_name, index_type, ityp_owner, ityp_name, status
FROM dba_indexes
WHERE owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
  AND (index_type = 'DOMAIN' OR ityp_name IS NOT NULL OR index_type LIKE '%SPATIAL%')
ORDER BY owner, index_name;
