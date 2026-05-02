/*
Oracle DBA Script: Table Pk Fk Health
Purpose: Provide Oracle DBA diagnostics for table pk fk health.
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

PROMPT Table Pk Fk Health

SELECT t.owner, t.table_name,
       SUM(CASE WHEN c.constraint_type = 'P' THEN 1 ELSE 0 END) AS pk_count,
       SUM(CASE WHEN c.constraint_type = 'R' THEN 1 ELSE 0 END) AS fk_count,
       SUM(CASE WHEN c.status <> 'ENABLED' THEN 1 ELSE 0 END) AS disabled_constraints
FROM dba_tables t
LEFT JOIN dba_constraints c ON c.owner = t.owner AND c.table_name = t.table_name
WHERE t.owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
GROUP BY t.owner, t.table_name
ORDER BY disabled_constraints DESC, fk_count DESC, t.owner, t.table_name;
