/*
Oracle DBA Script: ASH Resource By Service Module
Purpose: Attribute historical ASH load to service/module/action.
Area: Sql Resource Attribution
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Review findings before taking action. AWR/ASH scripts require appropriate licensing and catalog privileges.
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

PROMPT ASH Resource By Service Module

DEFINE days_back = 7
SELECT service_hash,
       module,
       action,
       NVL(wait_class, 'ON CPU') AS wait_class,
       COUNT(*) AS ash_samples,
       ROUND(COUNT(*) * 10 / 60, 1) AS estimated_active_minutes
FROM dba_hist_active_sess_history
WHERE sample_time >= SYSTIMESTAMP - NUMTODSINTERVAL(&&days_back, 'DAY')
GROUP BY service_hash, module, action, NVL(wait_class, 'ON CPU')
ORDER BY ash_samples DESC;
