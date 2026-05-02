/*
Oracle DBA Script: Duplicate Indexes
Purpose: Provide Oracle DBA diagnostics for duplicate indexes.
Area: Index Analysis
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

PROMPT Duplicate Indexes

WITH index_cols AS (
    SELECT index_owner, table_owner, table_name, index_name,
           LISTAGG(column_name, ',') WITHIN GROUP (ORDER BY column_position) AS columns_key
    FROM dba_ind_columns
    WHERE index_owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
    GROUP BY index_owner, table_owner, table_name, index_name
)
SELECT table_owner, table_name, columns_key,
       COUNT(*) AS index_count,
       LISTAGG(index_owner || '.' || index_name, '; ') WITHIN GROUP (ORDER BY index_owner, index_name) AS indexes
FROM index_cols
GROUP BY table_owner, table_name, columns_key
HAVING COUNT(*) > 1
ORDER BY index_count DESC, table_owner, table_name;
