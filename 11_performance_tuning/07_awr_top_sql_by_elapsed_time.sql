/*
Oracle DBA Script: AWR Top SQL By Elapsed Time
Purpose: Rank SQL by elapsed time using AWR SQLSTAT deltas.
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

PROMPT AWR Top SQL By Elapsed Time

DEFINE days_back = 7
WITH sql_agg AS (
    SELECT st.sql_id,
           MAX(st.parsing_schema_name) AS parsing_schema_name,
           MAX(st.module) AS module,
           SUM(st.executions_delta) AS executions,
           SUM(st.elapsed_time_delta) AS elapsed_us,
           SUM(st.cpu_time_delta) AS cpu_us,
           SUM(st.iowait_delta) AS iowait_us,
           SUM(st.buffer_gets_delta) AS buffer_gets,
           SUM(st.disk_reads_delta) AS disk_reads,
           SUM(st.rows_processed_delta) AS rows_processed,
           SUM(st.elapsed_time_delta) AS rank_value
    FROM dba_hist_sqlstat st
    JOIN dba_hist_snapshot sn ON sn.dbid = st.dbid AND sn.snap_id = st.snap_id AND sn.instance_number = st.instance_number
    WHERE sn.begin_interval_time >= SYSDATE - &&days_back
    GROUP BY st.sql_id
)
SELECT * FROM (
    SELECT a.sql_id,
           a.parsing_schema_name,
           a.module,
           a.executions,
           ROUND(a.elapsed_us/1000000, 2) AS elapsed_seconds,
           ROUND(a.cpu_us/1000000, 2) AS cpu_seconds,
           ROUND(a.iowait_us/1000000, 2) AS io_wait_seconds,
           a.buffer_gets,
           a.disk_reads,
           a.rows_processed,
           DBMS_LOB.SUBSTR(t.sql_text, 180, 1) AS sql_text_sample
    FROM sql_agg a
    LEFT JOIN dba_hist_sqltext t ON t.sql_id = a.sql_id
    ORDER BY a.rank_value DESC NULLS LAST
) WHERE ROWNUM <= 50;
