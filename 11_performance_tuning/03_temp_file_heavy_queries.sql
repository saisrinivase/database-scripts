/*
Oracle DBA Script: Temp File Heavy Queries
Purpose: Provide Oracle DBA diagnostics for temp file heavy queries.
Area: Performance Tuning
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

PROMPT Temp File Heavy Queries

SELECT s.inst_id, s.sid, s.serial# AS serial_num, u.username, u.sql_id,
       u.tablespace, u.segtype, ROUND(u.blocks * ts.block_size / 1024 / 1024, 2) AS temp_mb
FROM gv$tempseg_usage u
JOIN gv$session s ON s.inst_id = u.inst_id AND s.saddr = u.session_addr
JOIN dba_tablespaces ts ON ts.tablespace_name = u.tablespace
ORDER BY temp_mb DESC;
