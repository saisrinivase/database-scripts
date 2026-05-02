/*
Oracle DBA Script: ASH Top SQL Last Hour
Purpose: Identify current in-memory ASH top SQL for the last hour.
Area: Performance Tuning
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Review findings before taking action. AWR/ASH scripts require appropriate licensing and catalog privileges.
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

PROMPT ASH Top SQL Last Hour

SELECT * FROM (
    SELECT sql_id,
           session_state,
           NVL(wait_class, 'ON CPU') AS wait_class,
           NVL(event, 'ON CPU') AS event,
           COUNT(*) AS ash_samples,
           ROUND(COUNT(*) / 60, 2) AS estimated_active_minutes,
           MAX(module) AS sample_module,
           MAX(machine) AS sample_machine
    FROM gv$active_session_history
    WHERE sample_time >= SYSTIMESTAMP - INTERVAL '1' HOUR
      AND sql_id IS NOT NULL
    GROUP BY sql_id, session_state, NVL(wait_class, 'ON CPU'), NVL(event, 'ON CPU')
    ORDER BY ash_samples DESC
) WHERE ROWNUM <= 50;
