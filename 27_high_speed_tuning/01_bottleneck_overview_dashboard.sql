/*
Oracle DBA Script: Bottleneck Overview Dashboard
Purpose: Provide Oracle DBA diagnostics for bottleneck overview dashboard.
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

PROMPT Bottleneck Overview Dashboard

SELECT metric_name, ROUND(value,2) AS value, metric_unit
FROM v$sysmetric
WHERE group_id = 2
  AND metric_name IN ('Database CPU Time Ratio','Database Wait Time Ratio','Executions Per Sec','Logical Reads Per Sec','Physical Reads Per Sec','Redo Generated Per Sec','User Transaction Per Sec')
ORDER BY metric_name;
