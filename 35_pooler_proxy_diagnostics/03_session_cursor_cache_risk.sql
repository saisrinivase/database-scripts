/*
Oracle DBA Script: Session Cursor Cache Risk
Purpose: Provide Oracle DBA diagnostics for session cursor cache risk.
Area: Pooler Proxy Diagnostics
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

PROMPT Session Cursor Cache Risk

SELECT ss.inst_id, ss.sid, sn.name, ss.value
FROM gv$sesstat ss
JOIN gv$statname sn ON sn.inst_id = ss.inst_id AND sn.statistic# = ss.statistic#
WHERE sn.name IN ('session cursor cache hits','parse count (total)','parse count (hard)','opened cursors current')
ORDER BY ss.value DESC;
