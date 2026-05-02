/*
Oracle DBA Script: Chatty Small Result Queries
Purpose: Provide Oracle DBA diagnostics for chatty small result queries.
Area: Application Orm Performance
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

PROMPT Chatty Small Result Queries

SELECT * FROM (
    SELECT sql_id, parsing_schema_name, executions,
           ROUND(elapsed_time/NULLIF(executions,0)/1000000,6) AS avg_elapsed_seconds,
           rows_processed/NULLIF(executions,0) AS avg_rows,
           SUBSTR(sql_text,1,160) AS sql_text
    FROM v$sqlarea
    WHERE executions >= 1000
    ORDER BY executions DESC
) WHERE ROWNUM <= 100;
