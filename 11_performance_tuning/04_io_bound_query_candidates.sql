/*
Oracle DBA Script: Io Bound Query Candidates
Purpose: Provide Oracle DBA diagnostics for io bound query candidates.
Area: Performance Tuning
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

PROMPT Io Bound Query Candidates

SELECT * FROM (
    SELECT inst_id, sql_id, parsing_schema_name, executions, disk_reads, buffer_gets,
           ROUND(disk_reads / NULLIF(buffer_gets,0) * 100, 2) AS disk_to_buffer_pct,
           ROUND(elapsed_time/1000000,2) AS elapsed_seconds,
           SUBSTR(sql_text,1,120) AS sql_text
    FROM gv$sqlarea
    WHERE buffer_gets > 0
    ORDER BY disk_reads DESC
) WHERE ROWNUM <= 50;
