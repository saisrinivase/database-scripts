/*
Oracle DBA Script: Backup Pitr Configuration Health
Purpose: Provide Oracle DBA diagnostics for backup pitr configuration health.
Area: Backup Restore Pitr Dr
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

PROMPT Backup Pitr Configuration Health

SELECT name, value
FROM v$parameter
WHERE name IN ('db_recovery_file_dest','db_recovery_file_dest_size','control_file_record_keep_time','log_archive_dest_1','log_archive_format')
UNION ALL
SELECT 'log_mode', log_mode FROM v$database;
