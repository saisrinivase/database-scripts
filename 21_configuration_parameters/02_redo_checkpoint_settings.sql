/*
Oracle DBA Script: Redo Checkpoint Settings
Purpose: Provide Oracle DBA diagnostics for redo checkpoint settings.
Area: Configuration Parameters
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

PROMPT Redo Checkpoint Settings

SELECT name AS parameter_name, value, isdefault, ismodified, issys_modifiable, description
FROM v$parameter
WHERE name IN ('log_checkpoint_timeout','log_checkpoint_interval','fast_start_mttr_target','log_buffer','archive_lag_target','control_file_record_keep_time')
ORDER BY name;
