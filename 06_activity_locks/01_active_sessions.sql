/*
Oracle DBA Script: Active Sessions
Purpose: Provide Oracle DBA diagnostics for active sessions.
Area: Activity Locks
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

PROMPT Active Sessions

SELECT inst_id, sid, serial# AS serial_num, username, status, state,
       event, wait_class, seconds_in_wait, sql_id, module, machine, program, logon_time
FROM gv$session
WHERE username IS NOT NULL
ORDER BY status, last_call_et DESC;
