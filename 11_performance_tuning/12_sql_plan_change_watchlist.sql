/*
Oracle DBA Script: SQL Plan Change Watchlist
Purpose: Find high-resource SQL with multiple AWR plan hash values.
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

PROMPT SQL Plan Change Watchlist

DEFINE days_back = 14
WITH plans AS (
    SELECT st.sql_id,
           COUNT(DISTINCT st.plan_hash_value) AS plan_count,
           SUM(st.elapsed_time_delta) AS elapsed_us,
           SUM(st.executions_delta) AS executions,
           MIN(sn.begin_interval_time) AS first_seen,
           MAX(sn.end_interval_time) AS last_seen
    FROM dba_hist_sqlstat st
    JOIN dba_hist_snapshot sn ON sn.dbid = st.dbid AND sn.snap_id = st.snap_id AND sn.instance_number = st.instance_number
    WHERE sn.begin_interval_time >= SYSDATE - &&days_back
    GROUP BY st.sql_id
    HAVING COUNT(DISTINCT st.plan_hash_value) > 1
)
SELECT * FROM (
    SELECT p.sql_id,
           p.plan_count,
           p.executions,
           ROUND(p.elapsed_us/1000000, 2) AS elapsed_seconds,
           p.first_seen,
           p.last_seen,
           DBMS_LOB.SUBSTR(t.sql_text, 180, 1) AS sql_text_sample
    FROM plans p
    LEFT JOIN dba_hist_sqltext t ON t.sql_id = p.sql_id
    ORDER BY p.elapsed_us DESC
) WHERE ROWNUM <= 100;
