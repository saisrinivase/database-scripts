/*
Oracle DBA Script: Like Query Candidates
Purpose: Provide Oracle DBA diagnostics for like query candidates.
Area: Complex Filter Search
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

PROMPT Like Query Candidates

SELECT * FROM (
    SELECT sql_id, parsing_schema_name, executions, buffer_gets, disk_reads,
           SUBSTR(sql_text,1,200) AS sql_text
    FROM v$sqlarea
    WHERE REGEXP_LIKE(UPPER(sql_text), ' LIKE | REGEXP_LIKE')
    ORDER BY buffer_gets DESC
) WHERE ROWNUM <= 100;
