/*
Oracle DBA Script: Stats Gathering Job Pressure
Purpose: Provide Oracle DBA diagnostics for stats gathering job pressure.
Area: Db Writer Memory Pressure
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

PROMPT Stats Gathering Job Pressure

SELECT owner, job_name, enabled, state, last_start_date, next_run_date, run_count, failure_count
FROM dba_scheduler_jobs
WHERE job_name LIKE '%STATS%' OR program_name LIKE '%STATS%'
ORDER BY owner, job_name;
