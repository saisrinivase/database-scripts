/*
Oracle DBA Script: Missing Index Candidates From Scan Pressure
Purpose: Provide Oracle DBA diagnostics for missing index candidates from scan pressure.
Area: High Speed Tuning
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

PROMPT Missing Index Candidates From Scan Pressure

SELECT * FROM (
    SELECT sql_id, plan_hash_value, object_owner, object_name, options, operation, COUNT(*) AS plan_occurrences
    FROM dba_hist_sql_plan
    WHERE operation = 'TABLE ACCESS'
      AND options LIKE '%FULL%'
    GROUP BY sql_id, plan_hash_value, object_owner, object_name, options, operation
    ORDER BY plan_occurrences DESC
) WHERE ROWNUM <= 100;
