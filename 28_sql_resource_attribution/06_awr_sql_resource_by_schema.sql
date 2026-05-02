/*
Oracle DBA Script: AWR SQL Resource By Schema
Purpose: Aggregate AWR SQL resource deltas by parsing schema.
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

PROMPT AWR SQL Resource By Schema

DEFINE days_back = 7
SELECT NVL(st.parsing_schema_name, 'UNKNOWN') AS parsing_schema_name,
       SUM(st.executions_delta) AS executions,
       ROUND(SUM(st.elapsed_time_delta)/1000000, 2) AS elapsed_seconds,
       ROUND(SUM(st.cpu_time_delta)/1000000, 2) AS cpu_seconds,
       ROUND(SUM(st.iowait_delta)/1000000, 2) AS io_wait_seconds,
       SUM(st.buffer_gets_delta) AS buffer_gets,
       SUM(st.disk_reads_delta) AS disk_reads,
       SUM(st.rows_processed_delta) AS rows_processed
FROM dba_hist_sqlstat st
JOIN dba_hist_snapshot sn ON sn.dbid = st.dbid AND sn.snap_id = st.snap_id AND sn.instance_number = st.instance_number
WHERE sn.begin_interval_time >= SYSDATE - &&days_back
GROUP BY NVL(st.parsing_schema_name, 'UNKNOWN')
ORDER BY elapsed_seconds DESC;
