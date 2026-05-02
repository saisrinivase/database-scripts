/*
Oracle DBA Script: Options Components Installed
Purpose: Provide Oracle DBA diagnostics for options components installed.
Area: Environment
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

PROMPT Options Components Installed

SELECT 'DATABASE_OPTION' AS inventory_type, parameter AS name, value AS status, NULL AS version
FROM v$option
UNION ALL
SELECT 'REGISTRY_COMPONENT', comp_name, status, version
FROM dba_registry
ORDER BY inventory_type, name;
