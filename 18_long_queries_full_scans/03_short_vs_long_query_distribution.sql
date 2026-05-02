/*
Oracle DBA Script: Short Vs Long Query Distribution
Purpose: Provide Oracle DBA diagnostics for short vs long query distribution.
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

PROMPT Short Vs Long Query Distribution

SELECT CASE
         WHEN elapsed_time/NULLIF(executions,0)/1000000 < 1 THEN '<1s'
         WHEN elapsed_time/NULLIF(executions,0)/1000000 < 10 THEN '1-10s'
         WHEN elapsed_time/NULLIF(executions,0)/1000000 < 60 THEN '10-60s'
         ELSE '>=60s'
       END AS avg_elapsed_bucket,
       COUNT(*) AS sql_count
FROM gv$sqlarea
WHERE executions > 0
GROUP BY CASE
         WHEN elapsed_time/NULLIF(executions,0)/1000000 < 1 THEN '<1s'
         WHEN elapsed_time/NULLIF(executions,0)/1000000 < 10 THEN '1-10s'
         WHEN elapsed_time/NULLIF(executions,0)/1000000 < 60 THEN '10-60s'
         ELSE '>=60s'
       END
ORDER BY sql_count DESC;
