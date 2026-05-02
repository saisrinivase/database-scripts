/*
Oracle DBA Script: Connection State Distribution
Purpose: Provide Oracle DBA diagnostics for connection state distribution.
Area: Connection Workload
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

PROMPT Connection State Distribution

SELECT inst_id, status, state, wait_class, COUNT(*) AS session_count
FROM gv$session
WHERE username IS NOT NULL
GROUP BY inst_id, status, state, wait_class
ORDER BY session_count DESC;
