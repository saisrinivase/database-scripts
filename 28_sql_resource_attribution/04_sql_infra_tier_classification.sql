/*
Oracle DBA Script: Sql Infra Tier Classification
Purpose: Provide Oracle DBA diagnostics for sql infra tier classification.
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

PROMPT Sql Infra Tier Classification

SELECT sql_id, parsing_schema_name,
       CASE
         WHEN disk_reads > buffer_gets * 0.2 THEN 'STORAGE_IO_HEAVY'
         WHEN cpu_time > elapsed_time * 0.7 THEN 'CPU_HEAVY'
         WHEN sharable_mem > 10485760 THEN 'SHARED_POOL_HEAVY'
         WHEN rows_processed > executions * 10000 THEN 'LARGE_RESULT_OR_BATCH'
         ELSE 'MIXED'
       END AS infra_tier,
       executions, buffer_gets, disk_reads, ROUND(cpu_time/1000000,2) AS cpu_seconds,
       ROUND(elapsed_time/1000000,2) AS elapsed_seconds,
       SUBSTR(sql_text,1,160) AS sql_text
FROM gv$sqlarea
WHERE executions > 0
ORDER BY elapsed_time DESC;
