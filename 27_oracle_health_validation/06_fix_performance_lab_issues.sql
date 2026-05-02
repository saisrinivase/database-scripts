/*
Oracle DBA Script: Fix Performance Lab Issues
Purpose: Provide Oracle DBA diagnostics for fix performance lab issues.
Area: Oracle Health Validation
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

PROMPT Fix Performance Lab Issues

PROMPT Optional lab script. Run only in a scratch schema.
CREATE TABLE oracle_perf_lab_fullscan AS
SELECT level AS id, MOD(level,100) AS group_id, RPAD('x',200,'x') AS payload
FROM dual CONNECT BY level <= 100000;
