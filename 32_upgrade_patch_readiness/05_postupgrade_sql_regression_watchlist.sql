/*
Oracle DBA Script: Postupgrade Sql Regression Watchlist
Purpose: Provide Oracle DBA diagnostics for postupgrade sql regression watchlist.
Area: Upgrade Patch Readiness
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

PROMPT Postupgrade Sql Regression Watchlist

SELECT sql_id, parsing_schema_name, executions,
       ROUND(elapsed_time/1000000,2) AS elapsed_seconds,
       ROUND(RATIO_TO_REPORT(elapsed_time) OVER () * 100,2) AS elapsed_pct,
       ROUND(cpu_time/1000000,2) AS cpu_seconds,
       ROUND(RATIO_TO_REPORT(cpu_time) OVER () * 100,2) AS cpu_pct,
       buffer_gets, disk_reads, SUBSTR(sql_text,1,120) AS sql_text
FROM gv$sqlarea
WHERE elapsed_time > 0
ORDER BY elapsed_time DESC;
