/*
Oracle DBA Script: Logging Configuration Sanity
Purpose: Provide Oracle DBA diagnostics for logging configuration sanity.
Area: Logging Error Signatures
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

PROMPT Logging Configuration Sanity

SELECT name, value
FROM v$diag_info
UNION ALL
SELECT name, value FROM v$parameter WHERE name IN ('diagnostic_dest','audit_trail','max_dump_file_size','trace_enabled')
ORDER BY name;
