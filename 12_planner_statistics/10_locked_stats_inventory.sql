/*
Oracle DBA Script: Locked Stats Inventory
Purpose: List tables with locked optimizer statistics.
Area: Planner Statistics
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only optimizer stats lock inventory.
*/
SET LINESIZE 220
SET PAGESIZE 200
SET TRIMSPOOL ON
SET TAB OFF
COLUMN owner FORMAT A28
COLUMN object_name FORMAT A38
COLUMN tablespace_name FORMAT A30
COLUMN sql_id FORMAT A14
COLUMN event FORMAT A48
COLUMN metric_name FORMAT A48
COLUMN parameter_name FORMAT A45
COLUMN value FORMAT A45

PROMPT Locked Stats Inventory

SELECT owner,
       table_name,
       stattype_locked,
       stale_stats,
       num_rows,
       blocks,
       last_analyzed
FROM dba_tab_statistics
WHERE object_type = 'TABLE'
  AND stattype_locked IS NOT NULL
ORDER BY owner, table_name;
