/*
PostgreSQL DBA Script: Restore To Timestamp Quick Test
Purpose: Quick SQL-only feasibility check for "Can we restore to timestamp X right now?".
Area: Backup, Restore, PITR, and DR
Usage: Edit target_restore_ts in params CTE before running.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH params AS (
    SELECT
        (clock_timestamp() - interval '2 hours')::timestamptz AS target_restore_ts
),
arch AS (
    SELECT
        archived_count,
        failed_count,
        last_archived_time,
        last_failed_time
    FROM pg_stat_archiver
),
base AS (
    SELECT
        p.target_restore_ts,
        a.archived_count,
        a.failed_count,
        a.last_archived_time,
        a.last_failed_time,
        current_setting('archive_mode', true) AS archive_mode,
        current_setting('archive_command', true) AS archive_command,
        current_setting('archive_library', true) AS archive_library,
        pg_is_in_recovery() AS is_standby
    FROM params p
    CROSS JOIN arch a
)
SELECT
    target_restore_ts,
    clock_timestamp() AS validation_time,
    archive_mode,
    coalesce(nullif(trim(archive_command), ''), '(empty)') AS archive_command,
    coalesce(nullif(trim(archive_library), ''), '(empty)') AS archive_library,
    archived_count,
    failed_count,
    last_archived_time,
    round(extract(epoch FROM (clock_timestamp() - target_restore_ts)) / 60.0, 2) AS target_age_minutes,
    round(extract(epoch FROM (clock_timestamp() - last_archived_time)) / 60.0, 2) AS last_archived_age_minutes,
    CASE
        WHEN archive_mode NOT IN ('on', 'always') THEN 'NO: archive_mode disabled'
        WHEN coalesce(nullif(trim(archive_command), ''), nullif(trim(archive_library), '')) IS NULL THEN 'NO: archive shipping command/library missing'
        WHEN last_archived_time IS NULL THEN 'NO: no archived WAL evidence'
        WHEN target_restore_ts > clock_timestamp() THEN 'NO: target timestamp is in the future'
        WHEN target_restore_ts <= last_archived_time THEN 'LIKELY_YES: WAL coverage appears sufficient (validate base backup chain externally)'
        ELSE 'RISK: target newer than last archived WAL'
    END AS restore_to_timestamp_decision,
    CASE
        WHEN is_standby THEN 'Run this check on primary for archive freshness plus standby for replay lag.'
        ELSE 'Also verify last successful base backup and restore test evidence from backup tooling.'
    END AS operator_note
FROM base;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--        target_restore_ts       |        validation_time        | archive_mode | archive_command | archive_library | archived_count | failed_count | last_archived_time | target_age_minutes | last_archived_age_minutes | restore_to_timestamp_decision |                                     operator_note                                      
-- -------------------------------+-------------------------------+--------------+-----------------+-----------------+----------------+--------------+--------------------+--------------------+---------------------------+-------------------------------+----------------------------------------------------------------------------------------
--  2026-02-19 07:16:32.028678-05 | 2026-02-19 09:16:32.028722-05 | off          | (disabled)      | (empty)         |              0 |            0 |                    |             120.00 |                           | NO: archive_mode disabled     | Also verify last successful base backup and restore test evidence from backup tooling.
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
