/*
Oracle DBA Script: Long Queries From Statements
Purpose: Provide Oracle DBA diagnostics for long queries from statements.
Area: Long Queries Full Scans
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

PROMPT Long Queries From Statements

SELECT * FROM (
    SELECT inst_id, sql_id, parsing_schema_name, executions,
           ROUND(elapsed_time / NULLIF(executions,0) / 1000000, 4) AS avg_elapsed_seconds,
           ROUND(cpu_time / NULLIF(executions,0) / 1000000, 4) AS avg_cpu_seconds,
           buffer_gets / NULLIF(executions,0) AS avg_buffer_gets,
           disk_reads / NULLIF(executions,0) AS avg_disk_reads,
           SUBSTR(sql_text,1,120) AS sql_text
    FROM gv$sqlarea
    WHERE executions > 0
    ORDER BY elapsed_time / NULLIF(executions,0) DESC
) WHERE ROWNUM <= 50;
