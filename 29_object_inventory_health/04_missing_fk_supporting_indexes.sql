/*
Oracle DBA Script: Missing Fk Supporting Indexes
Purpose: Provide Oracle DBA diagnostics for missing fk supporting indexes.
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

PROMPT Missing Fk Supporting Indexes

WITH fk_cols AS (
    SELECT c.owner, c.table_name, c.constraint_name,
           LISTAGG(cc.column_name, ',') WITHIN GROUP (ORDER BY cc.position) AS fk_columns
    FROM dba_constraints c
    JOIN dba_cons_columns cc ON cc.owner = c.owner AND cc.constraint_name = c.constraint_name
    WHERE c.constraint_type = 'R'
      AND c.owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
    GROUP BY c.owner, c.table_name, c.constraint_name
), idx_cols AS (
    SELECT index_owner AS owner, table_name,
           LISTAGG(column_name, ',') WITHIN GROUP (ORDER BY column_position) AS index_columns
    FROM dba_ind_columns
    GROUP BY index_owner, table_name, index_name
)
SELECT f.owner, f.table_name, f.constraint_name, f.fk_columns
FROM fk_cols f
WHERE NOT EXISTS (
    SELECT 1 FROM idx_cols i
    WHERE i.owner = f.owner AND i.table_name = f.table_name AND i.index_columns LIKE f.fk_columns || '%'
)
ORDER BY f.owner, f.table_name, f.constraint_name;
