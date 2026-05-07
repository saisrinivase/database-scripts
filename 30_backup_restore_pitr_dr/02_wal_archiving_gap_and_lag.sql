/*
PostgreSQL DBA Script: WAL Archiving Gap And Lag
Purpose: Detect WAL archiving failure trends, archive recency gaps, and slot-retention pressure.
Area: Backup, Restore, PITR, and DR
Usage: Run on primary. Gaps/failures indicate PITR exposure.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH arch AS (
    SELECT
        archived_count,
        failed_count,
        last_archived_wal,
        last_archived_time,
        last_failed_wal,
        last_failed_time,
        stats_reset
    FROM pg_stat_archiver
),
wal AS (
    SELECT
        wal_records,
        wal_fpi,
        wal_bytes,
        stats_reset
    FROM pg_stat_wal
),
slot AS (
    SELECT
        count(*) AS slot_count,
        count(*) FILTER (WHERE active) AS active_slots,
        max(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS max_slot_retained_bytes,
        sum(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS total_slot_retained_bytes
    FROM pg_replication_slots
)
SELECT
    current_database() AS database_name,
    archived_count,
    failed_count,
    round(
        CASE WHEN archived_count + failed_count = 0 THEN 0
             ELSE 100.0 * failed_count::numeric / (archived_count + failed_count)
        END,
        2
    ) AS archive_failure_pct,
    last_archived_wal,
    last_archived_time,
    round(extract(epoch FROM (clock_timestamp() - last_archived_time))::numeric, 1) AS seconds_since_last_archived,
    last_failed_wal,
    last_failed_time,
    round(wal_bytes / 1024.0 / 1024.0 / 1024.0, 2) AS wal_generated_since_reset_gb,
    slot_count,
    active_slots,
    round(coalesce(max_slot_retained_bytes, 0) / 1024.0 / 1024.0 / 1024.0, 2) AS max_slot_retained_gb,
    round(coalesce(total_slot_retained_bytes, 0) / 1024.0 / 1024.0 / 1024.0, 2) AS total_slot_retained_gb,
    CASE
        WHEN last_archived_time IS NULL THEN 'NO_ARCHIVE_ACTIVITY'
        WHEN extract(epoch FROM (clock_timestamp() - last_archived_time)) > 900 THEN 'ARCHIVE_GAP_GT_15_MIN'
        WHEN failed_count > 0 AND last_failed_time > clock_timestamp() - interval '1 hour' THEN 'RECENT_ARCHIVE_FAILURES'
        ELSE 'ARCHIVE_HEALTHY'
    END AS pitr_archive_health,
    arch.stats_reset AS archiver_stats_reset,
    wal.stats_reset AS wal_stats_reset
FROM arch
CROSS JOIN wal
CROSS JOIN slot;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  database_name | archived_count | failed_count | archive_failure_pct | last_archived_wal | last_archived_time | seconds_since_last_archived | last_failed_wal | last_failed_time | wal_generated_since_reset_gb | slot_count | active_slots | max_slot_retained_gb | total_slot_retained_gb | pitr_archive_health |     archiver_stats_reset      |        wal_stats_reset        
-- ---------------+----------------+--------------+---------------------+-------------------+--------------------+-----------------------------+-----------------+------------------+------------------------------+------------+--------------+----------------------+------------------------+---------------------+-------------------------------+-------------------------------
--  pgbench_test  |              0 |            0 |                0.00 |                   |                    |                             |                 |                  |                        32.61 |          0 |            0 |                 0.00 |                   0.00 | NO_ARCHIVE_ACTIVITY | 2026-01-31 20:40:48.109778-05 | 2026-01-31 20:40:48.109778-05
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
