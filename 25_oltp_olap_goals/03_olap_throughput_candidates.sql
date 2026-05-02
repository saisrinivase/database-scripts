/*
Oracle DBA Script: Olap Throughput Candidates
Purpose: Provide Oracle DBA diagnostics for olap throughput candidates.
Area: Oltp Olap Goals
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

PROMPT Olap Throughput Candidates

SELECT * FROM (
    SELECT sql_id, parsing_schema_name, executions, rows_processed, buffer_gets, disk_reads,
           ROUND(elapsed_time/1000000,2) AS elapsed_seconds,
           SUBSTR(sql_text,1,160) AS sql_text
    FROM v$sqlarea
    ORDER BY rows_processed DESC NULLS LAST, elapsed_time DESC
) WHERE ROWNUM <= 50;
