/*
Oracle DBA Script: ASH Wait Event Trend
Purpose: Trend historical ASH wait events by hour for incident analysis.
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

PROMPT ASH Wait Event Trend

DEFINE days_back = 7
SELECT TRUNC(sample_time, 'HH24') AS sample_hour,
       NVL(wait_class, 'ON CPU') AS wait_class,
       NVL(event, 'ON CPU') AS event,
       COUNT(*) AS ash_samples,
       ROUND(COUNT(*) * 10 / 60, 1) AS estimated_active_minutes
FROM dba_hist_active_sess_history
WHERE sample_time >= SYSTIMESTAMP - NUMTODSINTERVAL(&&days_back, 'DAY')
  AND NVL(wait_class, 'ON CPU') <> 'Idle'
GROUP BY TRUNC(sample_time, 'HH24'), NVL(wait_class, 'ON CPU'), NVL(event, 'ON CPU')
ORDER BY sample_hour DESC, ash_samples DESC;
