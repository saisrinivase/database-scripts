/*
Oracle DBA Script: Planner Cost Settings
Purpose: Provide Oracle DBA diagnostics for planner cost settings.
Area: Planner Statistics
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

PROMPT Planner Cost Settings

SELECT o.owner, o.target, o.target_type, o.operation, o.status, o.start_time, o.end_time,
       o.job_name, o.notes
FROM dba_optstat_operations o
WHERE o.start_time >= SYSTIMESTAMP - INTERVAL '14' DAY
ORDER BY o.start_time DESC;
