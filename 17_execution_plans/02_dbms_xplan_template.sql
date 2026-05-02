/*
Oracle DBA Script: Dbms Xplan Template
Purpose: Provide Oracle DBA diagnostics for dbms xplan template.
Area: Execution Plans
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

PROMPT Dbms Xplan Template

PROMPT Replace &&sql_id with the target SQL_ID before running.
SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&&sql_id', NULL, 'ALLSTATS LAST +PEEKED_BINDS +OUTLINE +NOTE'));
