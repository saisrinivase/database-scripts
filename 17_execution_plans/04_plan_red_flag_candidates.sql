/*
Oracle DBA Script: Plan Red Flag Candidates
Purpose: Provide Oracle DBA diagnostics for plan red flag candidates.
Area: Execution Plans
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

PROMPT Plan Red Flag Candidates

SELECT * FROM (
    SELECT sql_id, plan_hash_value, operation, options, object_owner, object_name,
           cardinality, bytes, cost, temp_space
    FROM v$sql_plan
    WHERE operation IN ('TABLE ACCESS','INDEX','HASH JOIN','SORT')
      AND (options LIKE '%FULL%' OR temp_space > 0 OR cost > 100000)
    ORDER BY cost DESC NULLS LAST
) WHERE ROWNUM <= 100;
