/*
Oracle DBA Script: Tables Missing Primary Key
Purpose: Provide Oracle DBA diagnostics for tables missing primary key.
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

PROMPT Tables Missing Primary Key

SELECT t.owner, t.table_name, t.num_rows, t.partitioned, t.iot_type
FROM dba_tables t
WHERE t.owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
  AND t.temporary = 'N'
  AND NOT EXISTS (
      SELECT 1 FROM dba_constraints c
      WHERE c.owner = t.owner AND c.table_name = t.table_name AND c.constraint_type = 'P'
  )
ORDER BY t.num_rows DESC NULLS LAST;
