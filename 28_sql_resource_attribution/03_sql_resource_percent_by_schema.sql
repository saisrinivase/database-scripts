/*
Oracle DBA Script: Sql Resource Percent By Schema
Purpose: Provide Oracle DBA diagnostics for sql resource percent by schema.
Area: Sql Resource Attribution
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

PROMPT Sql Resource Percent By Schema

SELECT parsing_schema_name, COUNT(*) AS sql_count,
       ROUND(SUM(elapsed_time)/1000000,2) AS elapsed_seconds,
       ROUND(RATIO_TO_REPORT(SUM(elapsed_time)) OVER () * 100,2) AS elapsed_pct,
       SUM(buffer_gets) AS buffer_gets, SUM(disk_reads) AS disk_reads
FROM gv$sqlarea
GROUP BY parsing_schema_name
ORDER BY elapsed_seconds DESC;
