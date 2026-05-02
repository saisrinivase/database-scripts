/*
Oracle DBA Script: Shared Server Pooling Risk
Purpose: Provide Oracle DBA diagnostics for shared server pooling risk.
Area: Pooler Proxy Diagnostics
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

PROMPT Shared Server Pooling Risk

SELECT 'SHARED_SERVER' AS component, name, status, messages, bytes, breaks, idle, busy
FROM v$shared_server
UNION ALL
SELECT 'DISPATCHER', name, status, messages, bytes, breaks, idle, busy
FROM v$dispatcher
ORDER BY component, name;
