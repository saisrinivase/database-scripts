/*
Oracle DBA Script: Backup Restore Evidence Contract
Purpose: Provide Oracle DBA diagnostics for backup restore evidence contract.
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

PROMPT Backup Restore Evidence Contract

SELECT name, scn, time, database_incarnation#, guarantee_flashback_database, storage_size
FROM v$restore_point
ORDER BY time DESC;
