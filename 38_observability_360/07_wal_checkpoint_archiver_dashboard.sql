/*
PostgreSQL DBA Script: WAL Checkpoint Archiver Dashboard
Purpose: Summarize WAL generation, WAL write pressure, checkpoint pressure, and archive health.
Area: Observability 360
Usage: Run when storage, write latency, PITR, archiving, or checkpoint pressure is suspected.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Checkpointer view is version-guarded for PostgreSQL 17+.
*/
SELECT (current_setting('server_version_num')::int >= 170000) AS has_pg_stat_checkpointer \gset

\if :has_pg_stat_checkpointer
WITH wal AS (
    SELECT wal_records, wal_fpi, wal_bytes, wal_buffers_full, stats_reset
    FROM pg_stat_wal
),
archiver AS (
    SELECT archived_count, last_archived_wal, last_archived_time,
           failed_count, last_failed_wal, last_failed_time, stats_reset AS archiver_stats_reset
    FROM pg_stat_archiver
),
checkpoints AS (
    SELECT num_timed AS checkpoints_timed,
           num_requested AS checkpoints_requested,
           buffers_written AS buffers_checkpoint,
           write_time AS checkpoint_write_time,
           sync_time AS checkpoint_sync_time,
           stats_reset AS checkpoint_stats_reset
    FROM pg_stat_checkpointer
)
SELECT 'wal.bytes' AS metric_name, wal_bytes::numeric AS metric_value, 'bytes' AS unit, 'pg_stat_wal' AS source_view, 'Cumulative WAL bytes since reset.' AS purpose FROM wal
UNION ALL
SELECT 'wal.records', wal_records, 'count', 'pg_stat_wal', 'Cumulative WAL records since reset.' FROM wal
UNION ALL
SELECT 'wal.full_page_images', wal_fpi, 'count', 'pg_stat_wal', 'Full page images written to WAL since reset.' FROM wal
UNION ALL
SELECT 'wal.buffers_full', wal_buffers_full, 'count', 'pg_stat_wal', 'WAL buffer pressure events.' FROM wal
UNION ALL
SELECT 'checkpoints.requested_pct', round(100.0 * checkpoints_requested / NULLIF(checkpoints_timed + checkpoints_requested, 0), 2), 'percent', 'pg_stat_checkpointer', 'Requested checkpoint share.' FROM checkpoints
UNION ALL
SELECT 'checkpoints.write_time_ms', checkpoint_write_time, 'milliseconds', 'pg_stat_checkpointer', 'Cumulative checkpoint write time.' FROM checkpoints
UNION ALL
SELECT 'checkpoints.sync_time_ms', checkpoint_sync_time, 'milliseconds', 'pg_stat_checkpointer', 'Cumulative checkpoint sync time.' FROM checkpoints
UNION ALL
SELECT 'archiver.archived_count', archived_count, 'count', 'pg_stat_archiver', 'Successful archived WAL files.' FROM archiver
UNION ALL
SELECT 'archiver.failed_count', failed_count, 'count', 'pg_stat_archiver', 'Failed archive attempts.' FROM archiver
ORDER BY metric_name;
\else
WITH wal AS (
    SELECT wal_records, wal_fpi, wal_bytes, wal_buffers_full, stats_reset
    FROM pg_stat_wal
),
archiver AS (
    SELECT archived_count, last_archived_wal, last_archived_time,
           failed_count, last_failed_wal, last_failed_time, stats_reset AS archiver_stats_reset
    FROM pg_stat_archiver
),
checkpoints AS (
    SELECT checkpoints_timed,
           checkpoints_req AS checkpoints_requested,
           buffers_checkpoint,
           checkpoint_write_time,
           checkpoint_sync_time,
           stats_reset AS checkpoint_stats_reset
    FROM pg_stat_bgwriter
)
SELECT 'wal.bytes' AS metric_name, wal_bytes::numeric AS metric_value, 'bytes' AS unit, 'pg_stat_wal' AS source_view, 'Cumulative WAL bytes since reset.' AS purpose FROM wal
UNION ALL
SELECT 'wal.records', wal_records, 'count', 'pg_stat_wal', 'Cumulative WAL records since reset.' FROM wal
UNION ALL
SELECT 'wal.full_page_images', wal_fpi, 'count', 'pg_stat_wal', 'Full page images written to WAL since reset.' FROM wal
UNION ALL
SELECT 'wal.buffers_full', wal_buffers_full, 'count', 'pg_stat_wal', 'WAL buffer pressure events.' FROM wal
UNION ALL
SELECT 'checkpoints.requested_pct', round(100.0 * checkpoints_requested / NULLIF(checkpoints_timed + checkpoints_requested, 0), 2), 'percent', 'pg_stat_bgwriter', 'Requested checkpoint share.' FROM checkpoints
UNION ALL
SELECT 'checkpoints.write_time_ms', checkpoint_write_time, 'milliseconds', 'pg_stat_bgwriter', 'Cumulative checkpoint write time.' FROM checkpoints
UNION ALL
SELECT 'checkpoints.sync_time_ms', checkpoint_sync_time, 'milliseconds', 'pg_stat_bgwriter', 'Cumulative checkpoint sync time.' FROM checkpoints
UNION ALL
SELECT 'archiver.archived_count', archived_count, 'count', 'pg_stat_archiver', 'Successful archived WAL files.' FROM archiver
UNION ALL
SELECT 'archiver.failed_count', failed_count, 'count', 'pg_stat_archiver', 'Failed archive attempts.' FROM archiver
ORDER BY metric_name;
\endif

-- SAMPLE_OUTPUT_BEGIN
-- metric_name                | metric_value | unit         | source_view          | purpose
-- ---------------------------+--------------+--------------+----------------------+-------------------------------
-- archiver.failed_count      |            0 | count        | pg_stat_archiver     | Failed archive attempts.
-- checkpoints.requested_pct  |         4.77 | percent      | pg_stat_checkpointer | Requested checkpoint share.
-- wal.bytes                  |  12345678901 | bytes        | pg_stat_wal          | Cumulative WAL bytes since reset.
-- wal.records                |      9823741 | count        | pg_stat_wal          | Cumulative WAL records since reset.
-- SAMPLE_OUTPUT_END
