/*
Oracle DBA Script: Partition Target Table Deep Advisor
Purpose: Provide Oracle DBA diagnostics for partition target table deep advisor.
Area: Partitioning
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

PROMPT Partition Target Table Deep Advisor

SELECT owner, table_name, num_rows, blocks, last_analyzed, partitioned,
       CASE
         WHEN partitioned = 'YES' THEN 'ALREADY_PARTITIONED'
         WHEN num_rows >= 10000000 OR blocks >= 100000 THEN 'REVIEW_RANGE_OR_INTERVAL_PARTITIONING'
         WHEN last_analyzed < SYSDATE - 30 THEN 'GATHER_STATS_BEFORE_DECISION'
         ELSE 'LOW_PRIORITY'
       END AS partitioning_advice
FROM dba_tables
WHERE owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
  AND temporary = 'N'
ORDER BY CASE WHEN num_rows >= 10000000 OR blocks >= 100000 THEN 0 ELSE 1 END, num_rows DESC NULLS LAST;
