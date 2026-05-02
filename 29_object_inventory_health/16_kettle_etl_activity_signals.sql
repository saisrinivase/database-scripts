/*
Oracle DBA Script: Kettle Etl Activity Signals
Purpose: Provide Oracle DBA diagnostics for kettle etl activity signals.
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

PROMPT Kettle Etl Activity Signals

SELECT * FROM (
    SELECT sql_id, parsing_schema_name, module, action, executions, rows_processed,
           SUBSTR(sql_text,1,160) AS sql_text
    FROM v$sqlarea
    WHERE UPPER(module) LIKE '%KETTLE%' OR UPPER(module) LIKE '%PENTAHO%' OR UPPER(sql_text) LIKE '%KETTLE%'
    ORDER BY last_active_time DESC NULLS LAST
) WHERE ROWNUM <= 100;
