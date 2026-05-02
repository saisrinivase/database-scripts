/*
Oracle DBA Script: Scheduler Runbook
Purpose: Provide Oracle DBA diagnostics for scheduler runbook.
Area: Object Lifecycle Capacity
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

PROMPT Scheduler Runbook

BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'DBA_LIFECYCLE_SNAPSHOT_JOB',
    job_type        => 'STORED_PROCEDURE',
    job_action      => 'CAPTURE_DBA_LIFECYCLE_SNAPSHOT',
    repeat_interval => 'FREQ=DAILY;BYHOUR=1;BYMINUTE=0;BYSECOND=0',
    enabled         => TRUE
  );
END;
/
