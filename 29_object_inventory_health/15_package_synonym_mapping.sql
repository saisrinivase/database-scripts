/*
Oracle DBA Script: Package Synonym Mapping
Purpose: Provide Oracle DBA diagnostics for package synonym mapping.
Area: Object Inventory Health
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

PROMPT Package Synonym Mapping

SELECT s.owner AS synonym_owner, s.synonym_name, s.table_owner, s.table_name, s.db_link,
       o.object_type, o.status
FROM dba_synonyms s
LEFT JOIN dba_objects o ON o.owner = s.table_owner AND o.object_name = s.table_name
WHERE s.owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
  AND (o.object_type IN ('PACKAGE','PACKAGE BODY','PROCEDURE','FUNCTION') OR s.db_link IS NOT NULL)
ORDER BY s.owner, s.synonym_name;
