/*
Oracle DBA Script: Missing Join Column Indexes
Purpose: Provide Oracle DBA diagnostics for missing join column indexes.
Area: Object Inventory Health
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

PROMPT Missing Join Column Indexes

SELECT * FROM (
    SELECT sql_id, plan_hash_value, object_owner, object_name, options, operation, COUNT(*) AS plan_occurrences
    FROM dba_hist_sql_plan
    WHERE operation = 'TABLE ACCESS'
      AND options LIKE '%FULL%'
    GROUP BY sql_id, plan_hash_value, object_owner, object_name, options, operation
    ORDER BY plan_occurrences DESC
) WHERE ROWNUM <= 100;
