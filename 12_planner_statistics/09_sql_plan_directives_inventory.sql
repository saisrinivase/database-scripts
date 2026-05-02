/*
Oracle DBA Script: SQL Plan Directives Inventory
Purpose: List SQL plan directives for cardinality/statistics feedback review.
Area: Planner Statistics
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Oracle 12c+ SQL plan directives inventory. View availability varies by release and privilege.
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

PROMPT SQL Plan Directives Inventory

SELECT directive_id,
       type,
       state,
       reason,
       created,
       last_modified,
       last_used,
       notes
FROM dba_sql_plan_directives
ORDER BY last_modified DESC NULLS LAST;
