/*
PostgreSQL DBA Script: WAL Checkpoint Archiver Dashboard
Purpose: Summarize WAL generation, WAL write pressure, checkpoint pressure, and archive health.
Area: Observability 360
Usage: Run when storage, write latency, PITR, archiving, or checkpoint pressure is suspected.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. PostgreSQL 15+. Version-specific checkpoint views are handled with dynamic SQL.
*/

CREATE TEMP TABLE IF NOT EXISTS obs360_wal_checkpoint_report (
    metric_name text,
    metric_value numeric,
    unit text,
    status text,
    source_view text,
    purpose text,
    recommended_action text
);

TRUNCATE obs360_wal_checkpoint_report;

WITH wal AS (
    SELECT wal_records, wal_fpi, wal_bytes, wal_buffers_full, stats_reset
    FROM pg_stat_wal
),
archiver AS (
    SELECT archived_count, failed_count, last_archived_time, last_failed_time
    FROM pg_stat_archiver
)
INSERT INTO obs360_wal_checkpoint_report
SELECT 'wal.bytes', wal_bytes::numeric, 'bytes', 'INFO', 'pg_stat_wal',
       'Cumulative WAL bytes since reset.', 'Use two samples to calculate WAL generation rate.' FROM wal
UNION ALL
SELECT 'wal.records', wal_records::numeric, 'count', 'INFO', 'pg_stat_wal',
       'Cumulative WAL records since reset.', 'High deltas indicate write-heavy workload.' FROM wal
UNION ALL
SELECT 'wal.full_page_images', wal_fpi::numeric, 'count', 'INFO', 'pg_stat_wal',
       'Full page images written to WAL since reset.', 'High FPI can follow checkpoints or first changes after checkpoint.' FROM wal
UNION ALL
SELECT 'wal.buffers_full', wal_buffers_full::numeric, 'count',
       CASE WHEN wal_buffers_full > 0 THEN 'REVIEW' ELSE 'OK' END,
       'pg_stat_wal', 'WAL buffer pressure events.', 'If increasing quickly, review WAL buffers, write latency, and checkpoint cadence.' FROM wal
UNION ALL
SELECT 'archiver.archived_count', archived_count::numeric, 'count', 'INFO', 'pg_stat_archiver',
       'Successful archived WAL files.', 'Use delta over time to confirm archiving is active.' FROM archiver
UNION ALL
SELECT 'archiver.failed_count', failed_count::numeric, 'count',
       CASE WHEN failed_count > 0 THEN 'WARN' ELSE 'OK' END,
       'pg_stat_archiver', 'Failed archive attempts.', 'If nonzero or increasing, inspect archive_command and archive destination.' FROM archiver;

DO $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_checkpointer') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO obs360_wal_checkpoint_report
            SELECT 'checkpoints.requested_pct',
                   round(100.0 * num_requested / NULLIF(num_timed + num_requested, 0), 2),
                   'percent',
                   CASE WHEN (100.0 * num_requested / NULLIF(num_timed + num_requested, 0)) > 20 THEN 'WARN' ELSE 'OK' END,
                   'pg_stat_checkpointer',
                   'Requested checkpoint share.',
                   'High requested percentage can mean max_wal_size is too small for workload.'
            FROM pg_stat_checkpointer
            UNION ALL
            SELECT 'checkpoints.write_time_ms', write_time::numeric, 'milliseconds', 'INFO',
                   'pg_stat_checkpointer', 'Cumulative checkpoint write time.',
                   'Use deltas to identify checkpoint write pressure.'
            FROM pg_stat_checkpointer
            UNION ALL
            SELECT 'checkpoints.sync_time_ms', sync_time::numeric, 'milliseconds', 'INFO',
                   'pg_stat_checkpointer', 'Cumulative checkpoint sync time.',
                   'High sync deltas can indicate storage latency.'
            FROM pg_stat_checkpointer
        $sql$;
    ELSE
        EXECUTE $sql$
            INSERT INTO obs360_wal_checkpoint_report
            SELECT 'checkpoints.requested_pct',
                   round(100.0 * checkpoints_req / NULLIF(checkpoints_timed + checkpoints_req, 0), 2),
                   'percent',
                   CASE WHEN (100.0 * checkpoints_req / NULLIF(checkpoints_timed + checkpoints_req, 0)) > 20 THEN 'WARN' ELSE 'OK' END,
                   'pg_stat_bgwriter',
                   'Requested checkpoint share.',
                   'High requested percentage can mean max_wal_size is too small for workload.'
            FROM pg_stat_bgwriter
            UNION ALL
            SELECT 'checkpoints.write_time_ms', checkpoint_write_time::numeric, 'milliseconds', 'INFO',
                   'pg_stat_bgwriter', 'Cumulative checkpoint write time.',
                   'Use deltas to identify checkpoint write pressure.'
            FROM pg_stat_bgwriter
            UNION ALL
            SELECT 'checkpoints.sync_time_ms', checkpoint_sync_time::numeric, 'milliseconds', 'INFO',
                   'pg_stat_bgwriter', 'Cumulative checkpoint sync time.',
                   'High sync deltas can indicate storage latency.'
            FROM pg_stat_bgwriter
        $sql$;
    END IF;
END $$;

SELECT
    'step_01_wal_checkpoint_archiver' AS report_section,
    metric_name,
    metric_value,
    unit,
    status,
    source_view,
    purpose,
    recommended_action
FROM obs360_wal_checkpoint_report
ORDER BY
    CASE status WHEN 'CRITICAL' THEN 1 WHEN 'WARN' THEN 2 WHEN 'REVIEW' THEN 3 WHEN 'INFO' THEN 4 ELSE 5 END,
    metric_name;

-- SAMPLE_OUTPUT_BEGIN
-- report_section                 | metric_name               | metric_value | unit    | status | source_view
-- -------------------------------+---------------------------+--------------+---------+--------+---------------------
-- step_01_wal_checkpoint_archiver| archiver.failed_count     |            0 | count   | OK     | pg_stat_archiver
-- step_01_wal_checkpoint_archiver| checkpoints.requested_pct |         4.77 | percent | OK     | pg_stat_checkpointer
-- SAMPLE_OUTPUT_END
