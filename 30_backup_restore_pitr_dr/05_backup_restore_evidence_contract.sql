/*
PostgreSQL DBA Script: Backup Restore Evidence Contract
Purpose: Check whether a backup/restore evidence table exists for trend reporting (duration, size, success).
Area: Backup, Restore, PITR, and DR
Usage: Optional control-table contract for operational audits.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT (to_regclass('dba_metrics.backup_restore_history') IS NOT NULL) AS has_backup_history_contract \gset

\if :has_backup_history_contract
SELECT
    run_id,
    backup_type,
    backup_tool,
    backup_start_ts,
    backup_end_ts,
    round(extract(epoch FROM (backup_end_ts - backup_start_ts)) / 60.0, 2) AS duration_minutes,
    backup_size_bytes,
    round(backup_size_bytes / 1024.0 / 1024.0 / 1024.0, 2) AS backup_size_gb,
    success,
    restore_tested,
    restore_target_ts,
    restore_validation_ts,
    notes
FROM dba_metrics.backup_restore_history
ORDER BY backup_end_ts DESC
LIMIT 50;
\else
SELECT
    'MISSING_BACKUP_RESTORE_EVIDENCE' AS status,
    'Create dba_metrics.backup_restore_history to store last success, duration trend, size trend, and restore drill proof.' AS guidance,
    'Expected columns: run_id, backup_type, backup_tool, backup_start_ts, backup_end_ts, backup_size_bytes, success, restore_tested, restore_target_ts, restore_validation_ts, notes.' AS suggested_contract;
\endif


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--              status              |                                                       guidance                                                        |                                                                                suggested_contract                                                                                
-- ---------------------------------+-----------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  MISSING_BACKUP_RESTORE_EVIDENCE | Create dba_metrics.backup_restore_history to store last success, duration trend, size trend, and restore drill proof. | Expected columns: run_id, backup_type, backup_tool, backup_start_ts, backup_end_ts, backup_size_bytes, success, restore_tested, restore_target_ts, restore_validation_ts, notes.
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
