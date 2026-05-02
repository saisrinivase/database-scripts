/*
Oracle DBA Script: SQL Plan Baseline Inventory
Purpose: Inventory SQL plan baselines and their acceptance/enabled status.
Area: Execution Plans
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Requires access to DBA_SQL_PLAN_BASELINES.
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

PROMPT SQL Plan Baseline Inventory

SELECT sql_handle,
       plan_name,
       enabled,
       accepted,
       fixed,
       reproduced,
       autopurge,
       created,
       last_executed,
       optimizer_cost,
       executions,
       elapsed_time,
       cpu_time,
       buffer_gets,
       disk_reads
FROM dba_sql_plan_baselines
ORDER BY last_executed DESC NULLS LAST, created DESC;
