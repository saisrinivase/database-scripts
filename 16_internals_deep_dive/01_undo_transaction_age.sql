/*
Oracle DBA Script: Undo Transaction Age
Purpose: Provide Oracle DBA diagnostics for undo transaction age.
Area: Internals Deep Dive
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

PROMPT Undo Transaction Age

SELECT s.inst_id, s.sid, s.serial# AS serial_num, s.username, t.start_time,
       t.used_ublk, t.used_urec, t.status, s.sql_id, s.program
FROM gv$transaction t
JOIN gv$session s ON s.inst_id = t.inst_id AND s.taddr = t.addr
ORDER BY t.start_time;
