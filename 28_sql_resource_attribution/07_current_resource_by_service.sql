/*
Oracle DBA Script: Current Resource By Service
Purpose: Aggregate current cursor-cache SQL resource by service.
Area: Sql Resource Attribution
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only current cursor-cache aggregation.
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

PROMPT Current Resource By Service

SELECT service,
       COUNT(*) AS sql_count,
       SUM(executions) AS executions,
       ROUND(SUM(elapsed_time)/1000000, 2) AS elapsed_seconds,
       ROUND(SUM(cpu_time)/1000000, 2) AS cpu_seconds,
       SUM(buffer_gets) AS buffer_gets,
       SUM(disk_reads) AS disk_reads,
       SUM(rows_processed) AS rows_processed
FROM gv$sqlarea
GROUP BY service
ORDER BY elapsed_seconds DESC;
