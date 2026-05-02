/*
Oracle DBA Script: Display AWR Plan By SQL ID
Purpose: Display historical AWR execution plans for a supplied SQL_ID.
Area: Execution Plans
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Requires SELECT/READ on DBA_HIST_SQL_PLAN, DBA_HIST_SQLTEXT, and V$DATABASE; Diagnostics Pack licensing may apply.
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

PROMPT Display AWR Plan By SQL ID

PROMPT Set SQL_ID before running, for example: DEFINE sql_id = abc123xyz7890
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_AWR('&&sql_id', NULL, NULL, 'ALL +PEEKED_BINDS +NOTE'));
