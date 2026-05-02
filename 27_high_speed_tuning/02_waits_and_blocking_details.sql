/*
Oracle DBA Script: Waits And Blocking Details
Purpose: Provide Oracle DBA diagnostics for waits and blocking details.
Area: High Speed Tuning
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

PROMPT Waits And Blocking Details

SELECT wait_class, event, COUNT(*) AS sessions_waiting,
       MAX(seconds_in_wait) AS max_seconds_in_wait
FROM gv$session
WHERE state = 'WAITING'
  AND wait_class <> 'Idle'
GROUP BY wait_class, event
ORDER BY sessions_waiting DESC, max_seconds_in_wait DESC;
