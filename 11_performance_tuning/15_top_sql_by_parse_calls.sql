/*
Oracle DBA Script: Top SQL By Parse Calls
Purpose: Find SQL with high parse-call pressure in the cursor cache.
Area: Performance Tuning
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only cursor-cache check.
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

PROMPT Top SQL By Parse Calls

SELECT * FROM (
    SELECT inst_id,
           sql_id,
           parsing_schema_name,
           parse_calls,
           executions,
           ROUND(parse_calls / NULLIF(executions,0), 4) AS parses_per_exec,
           loads,
           invalidations,
           version_count,
           SUBSTR(sql_text, 1, 180) AS sql_text_sample
    FROM gv$sqlarea
    WHERE parse_calls > 0
    ORDER BY parse_calls DESC
) WHERE ROWNUM <= 100;
