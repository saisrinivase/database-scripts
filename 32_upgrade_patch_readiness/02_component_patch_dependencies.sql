/*
Oracle DBA Script: Component Patch Dependencies
Purpose: Provide Oracle DBA diagnostics for component patch dependencies.
Area: Upgrade Patch Readiness
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

PROMPT Component Patch Dependencies

SELECT r.comp_id, r.comp_name, r.version, r.status, p.patch_id, p.patch_type, p.action, p.status AS patch_status, p.action_time
FROM dba_registry r
LEFT JOIN dba_registry_sqlpatch p ON 1 = 1
ORDER BY r.comp_id, p.action_time DESC NULLS LAST;
