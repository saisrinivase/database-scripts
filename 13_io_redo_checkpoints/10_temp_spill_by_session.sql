/*
Oracle DBA Script: Temp Spill By Session
Purpose: Show sessions currently consuming temporary segments.
Area: Io Redo Checkpoints
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only current TEMP spill/session check.
*/
SET LINESIZE 220
SET PAGESIZE 200
SET TRIMSPOOL ON
SET TAB OFF
COLUMN owner FORMAT A28
COLUMN object_name FORMAT A38
COLUMN tablespace_name FORMAT A30
COLUMN sql_id FORMAT A14
COLUMN event FORMAT A48
COLUMN metric_name FORMAT A48
COLUMN parameter_name FORMAT A45
COLUMN value FORMAT A45

PROMPT Temp Spill By Session

SELECT s.inst_id,
       s.sid,
       s.serial# AS serial_num,
       s.username,
       s.status,
       s.sql_id,
       u.tablespace,
       u.segtype,
       ROUND(u.blocks * ts.block_size / 1024 / 1024, 2) AS temp_mb,
       s.module,
       s.machine,
       s.program
FROM gv$tempseg_usage u
JOIN gv$session s ON s.inst_id = u.inst_id AND s.saddr = u.session_addr
JOIN dba_tablespaces ts ON ts.tablespace_name = u.tablespace
ORDER BY temp_mb DESC;
