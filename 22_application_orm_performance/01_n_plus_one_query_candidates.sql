/*
Oracle DBA Script: N Plus One Query Candidates
Purpose: Provide Oracle DBA diagnostics for n plus one query candidates.
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

PROMPT N Plus One Query Candidates

SELECT * FROM (
    SELECT sql_id, parsing_schema_name, executions, loads, parse_calls, rows_processed,
           ROUND(parse_calls/NULLIF(executions,0),4) AS parses_per_exec,
           SUBSTR(sql_text,1,160) AS sql_text
    FROM v$sqlarea
    WHERE executions > 0
    ORDER BY parse_calls DESC
) WHERE ROWNUM <= 100;
