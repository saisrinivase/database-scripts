/*
Oracle DBA Script: Checksum Status And Failures
Purpose: Provide Oracle DBA diagnostics for checksum status and failures.
Area: Consistency Integrity Checks
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

PROMPT Checksum Status And Failures

SELECT 'DATABASE_BLOCK_CORRUPTION' AS source_view, COUNT(*) AS finding_count FROM v$database_block_corruption
UNION ALL SELECT 'BACKUP_CORRUPTION', COUNT(*) FROM v$backup_corruption
UNION ALL SELECT 'COPY_CORRUPTION', COUNT(*) FROM v$copy_corruption;
