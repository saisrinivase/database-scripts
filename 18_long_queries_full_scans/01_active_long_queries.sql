/*
Oracle DBA Script: Active Long Queries
Purpose: Provide Oracle DBA diagnostics for active long queries.
Area: Long Queries Full Scans
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

PROMPT Active Long Queries

SELECT inst_id, sid, serial# AS serial_num, username, status, sql_id,
       event, wait_class, last_call_et AS seconds_since_call,
       ROUND(last_call_et/60,2) AS minutes_since_call, module, machine, program
FROM gv$session
WHERE username IS NOT NULL
  AND status = 'ACTIVE'
  AND last_call_et >= 300
ORDER BY last_call_et DESC;
