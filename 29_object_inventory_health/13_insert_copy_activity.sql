/*
Oracle DBA Script: Insert Copy Activity
Purpose: Provide Oracle DBA diagnostics for insert copy activity.
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

PROMPT Insert Copy Activity

SELECT table_owner AS owner, table_name, inserts, updates, deletes, truncated, timestamp AS last_modification_time
FROM dba_tab_modifications
WHERE table_owner NOT IN ('SYS','SYSTEM','XDB','CTXSYS','MDSYS','ORDSYS','OUTLN','WMSYS','DBSNMP','AUDSYS')
ORDER BY (NVL(inserts,0)+NVL(updates,0)+NVL(deletes,0)) DESC;
