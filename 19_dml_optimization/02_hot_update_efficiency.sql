/*
Oracle DBA Script: Hot Update Efficiency
Purpose: Provide Oracle DBA diagnostics for hot update efficiency.
Area: Dml Optimization
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

PROMPT Hot Update Efficiency

SELECT t.owner, t.table_name, t.row_movement, t.pct_free, t.ini_trans, t.num_rows, t.blocks,
       m.inserts, m.updates, m.deletes,
       CASE WHEN NVL(m.updates,0) > NVL(m.inserts,0) + NVL(m.deletes,0) THEN 'UPDATE_HEAVY_REVIEW_PCTFREE_INDEXES' ELSE 'NORMAL' END AS dml_profile
FROM dba_tables t
LEFT JOIN dba_tab_modifications m ON m.table_owner = t.owner AND m.table_name = t.table_name
WHERE t.owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
ORDER BY NVL(m.updates,0) DESC NULLS LAST;
