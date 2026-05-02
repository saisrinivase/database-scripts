/*
Oracle DBA Script: Lock Wait Deadlock Signatures
Purpose: Provide Oracle DBA diagnostics for lock wait deadlock signatures.
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

PROMPT Lock Wait Deadlock Signatures

SELECT inst_id, sid, serial# AS serial_num, username, event, seconds_in_wait, blocking_session, sql_id
FROM gv$session
WHERE wait_class = 'Application'
   OR event LIKE 'enq:%'
ORDER BY seconds_in_wait DESC;
