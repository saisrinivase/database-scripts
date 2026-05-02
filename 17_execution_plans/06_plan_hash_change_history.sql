/*
Oracle DBA Script: Plan Hash Change History
Purpose: Show plan hash changes over time for SQL with more than one historical plan.
Area: Execution Plans
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

PROMPT Plan Hash Change History

DEFINE days_back = 30
SELECT st.sql_id,
       st.plan_hash_value,
       MIN(sn.begin_interval_time) AS first_seen,
       MAX(sn.end_interval_time) AS last_seen,
       SUM(st.executions_delta) AS executions,
       ROUND(SUM(st.elapsed_time_delta)/1000000, 2) AS elapsed_seconds,
       ROUND(SUM(st.cpu_time_delta)/1000000, 2) AS cpu_seconds
FROM dba_hist_sqlstat st
JOIN dba_hist_snapshot sn ON sn.dbid = st.dbid AND sn.snap_id = st.snap_id AND sn.instance_number = st.instance_number
WHERE sn.begin_interval_time >= SYSDATE - &&days_back
  AND st.sql_id IN (
      SELECT sql_id
      FROM dba_hist_sqlstat
      GROUP BY sql_id
      HAVING COUNT(DISTINCT plan_hash_value) > 1
  )
GROUP BY st.sql_id, st.plan_hash_value
ORDER BY st.sql_id, first_seen;
