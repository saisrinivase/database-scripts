/*
Oracle DBA Script: Top Objects By ASH Wait
Purpose: Identify objects most associated with historical ASH wait samples.
Area: Sql Resource Attribution
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

PROMPT Top Objects By ASH Wait

DEFINE days_back = 7
SELECT * FROM (
    SELECT o.owner,
           o.object_name,
           o.object_type,
           h.wait_class,
           COUNT(*) AS ash_samples,
           ROUND(COUNT(*) * 10 / 60, 1) AS estimated_wait_minutes,
           COUNT(DISTINCT h.session_id) AS distinct_sessions
    FROM dba_hist_active_sess_history h
    LEFT JOIN dba_objects o ON o.object_id = h.current_obj#
    WHERE h.sample_time >= SYSTIMESTAMP - NUMTODSINTERVAL(&&days_back, 'DAY')
      AND h.current_obj# > 0
      AND h.session_state = 'WAITING'
      AND NVL(h.wait_class, 'Idle') NOT IN ('Idle','Network')
    GROUP BY o.owner, o.object_name, o.object_type, h.wait_class
    ORDER BY ash_samples DESC
) WHERE ROWNUM <= 100;
