/*
Oracle DBA Script: Blocking And Blocked Sessions
Purpose: Provide Oracle DBA diagnostics for blocking and blocked sessions.
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

PROMPT Blocking And Blocked Sessions

SELECT s.inst_id, s.sid, s.serial# AS serial_num, s.username, s.status,
       s.blocking_instance, s.blocking_session, s.event, s.wait_class,
       s.seconds_in_wait, s.sql_id, s.machine, s.program
FROM gv$session s
WHERE s.blocking_session IS NOT NULL
ORDER BY s.seconds_in_wait DESC;
