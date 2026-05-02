/*
Oracle DBA Script: Parameter Deprecated Settings
Purpose: Provide Oracle DBA diagnostics for parameter deprecated settings.
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

PROMPT Parameter Deprecated Settings

SELECT name AS parameter_name, value, isdefault, description
FROM v$parameter
WHERE isdeprecated = 'TRUE'
   OR name IN ('compatible','optimizer_features_enable','sec_case_sensitive_logon')
ORDER BY name;
