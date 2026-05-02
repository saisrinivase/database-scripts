/*
Oracle DBA Script: Restore Point Inventory
Purpose: Inventory normal and guaranteed restore points.
Area: Backup Restore Pitr Dr
Usage: Run with SQL*Plus or SQLcl as a user with SELECT_CATALOG_ROLE, DBA, or explicit access to the referenced DBA_/GV$/V$ views.
Notes: Read-only restore point inventory.
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

PROMPT Restore Point Inventory

SELECT name,
       scn,
       time,
       guarantee_flashback_database,
       storage_size,
       database_incarnation#
FROM v$restore_point
ORDER BY time DESC;
