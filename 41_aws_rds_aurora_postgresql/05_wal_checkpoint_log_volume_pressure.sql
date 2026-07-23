/*
PostgreSQL DBA Script: AWS WAL Checkpoint Log Volume Pressure
Purpose: Deep-dive CheckpointLag, TransactionLogsGeneration/DiskUsage, and dedicated log-volume I/O, latency, throughput, queue, and free-space alarms.
Area: AWS RDS and Aurora PostgreSQL
Usage: Run twice across the CloudWatch period for WAL rates; use AWS for managed log-volume capacity and queue metrics.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only except for a pg_temp function. Handles PostgreSQL 15/16 and 17+ checkpoint view differences.
*/
WITH wal AS (
    SELECT
        wal_records::numeric,
        wal_fpi::numeric,
        wal_bytes::numeric,
        wal_buffers_full::numeric,
        coalesce((to_jsonb(w) ->> 'wal_write')::numeric, 0) AS wal_write,
        coalesce((to_jsonb(w) ->> 'wal_sync')::numeric, 0) AS wal_sync,
        coalesce((to_jsonb(w) ->> 'wal_write_time')::numeric, 0) AS wal_write_time,
        coalesce((to_jsonb(w) ->> 'wal_sync_time')::numeric, 0) AS wal_sync_time,
        stats_reset
    FROM pg_stat_wal w
),
retention AS (
    SELECT
        coalesce(sum(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)), 0)::numeric AS slot_retained_wal_bytes,
        count(*) FILTER (WHERE NOT active) AS inactive_slots
    FROM pg_replication_slots
    WHERE restart_lsn IS NOT NULL
)
SELECT
    'wal_log_volume' AS report_section,
    w.wal_records,
    w.wal_fpi,
    round(100.0 * w.wal_fpi / NULLIF(w.wal_records, 0), 2) AS full_page_image_pct,
    w.wal_bytes,
    pg_size_pretty(w.wal_bytes::bigint) AS wal_bytes_pretty,
    w.wal_buffers_full,
    w.wal_write,
    w.wal_sync,
    round(w.wal_write_time / NULLIF(w.wal_write, 0), 3) AS average_wal_write_ms,
    round(w.wal_sync_time / NULLIF(w.wal_sync, 0), 3) AS average_wal_sync_ms,
    r.slot_retained_wal_bytes,
    pg_size_pretty(r.slot_retained_wal_bytes::bigint) AS slot_retained_wal_pretty,
    r.inactive_slots,
    w.stats_reset,
    CASE
        WHEN r.slot_retained_wal_bytes >= 10::numeric * 1024 * 1024 * 1024 THEN 'Replication slots retain at least 10 GB of WAL.'
        WHEN w.wal_buffers_full > 0 THEN 'Historical WAL-buffer-full events exist; calculate the interval delta.'
        WHEN w.wal_sync_time / NULLIF(w.wal_sync, 0) >= 10 THEN 'Average cumulative WAL sync time is at least 10 ms.'
        ELSE 'Capture a second snapshot; cumulative WAL counters do not prove current pressure.'
    END AS diagnosis
FROM wal w
CROSS JOIN retention r;

CREATE OR REPLACE FUNCTION pg_temp.aws_checkpoint_pressure()
RETURNS TABLE (
    source_view text,
    timed_checkpoints numeric,
    requested_checkpoints numeric,
    requested_checkpoint_pct numeric,
    checkpoint_write_time_ms numeric,
    checkpoint_sync_time_ms numeric,
    buffers_written numeric,
    stats_reset timestamptz,
    diagnosis text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_checkpointer') IS NOT NULL THEN
        RETURN QUERY EXECUTE $query$
            SELECT
                'pg_stat_checkpointer',
                num_timed::numeric,
                num_requested::numeric,
                round(100.0 * num_requested / NULLIF(num_timed + num_requested, 0), 2),
                write_time::numeric,
                sync_time::numeric,
                buffers_written::numeric,
                stats_reset,
                CASE
                    WHEN 100.0 * num_requested / NULLIF(num_timed + num_requested, 0) >= 20
                        THEN 'Requested checkpoint percentage is high; review WAL volume and max_wal_size.'
                    ELSE 'Compare checkpoint deltas and duration with the CloudWatch alarm period.'
                END
            FROM pg_stat_checkpointer
        $query$;
    ELSE
        RETURN QUERY EXECUTE $query$
            SELECT
                'pg_stat_bgwriter',
                checkpoints_timed::numeric,
                checkpoints_req::numeric,
                round(100.0 * checkpoints_req / NULLIF(checkpoints_timed + checkpoints_req, 0), 2),
                checkpoint_write_time::numeric,
                checkpoint_sync_time::numeric,
                buffers_checkpoint::numeric,
                stats_reset,
                CASE
                    WHEN 100.0 * checkpoints_req / NULLIF(checkpoints_timed + checkpoints_req, 0) >= 20
                        THEN 'Requested checkpoint percentage is high; review WAL volume and max_wal_size.'
                    ELSE 'Compare checkpoint deltas and duration with the CloudWatch alarm period.'
                END
            FROM pg_stat_bgwriter
        $query$;
    END IF;
END;
$$;

SELECT *
FROM pg_temp.aws_checkpoint_pressure();

SELECT
    backend_type,
    wait_event_type,
    wait_event,
    count(*) AS waiting_backends,
    max(clock_timestamp() - query_start) AS longest_query_age,
    string_agg(DISTINCT regexp_replace(query, '\s+', ' ', 'g'), E'\n') AS complete_query_texts
FROM pg_stat_activity
WHERE wait_event ILIKE '%wal%'
   OR wait_event ILIKE '%checkpoint%'
   OR wait_event ILIKE '%sync%'
GROUP BY backend_type, wait_event_type, wait_event
ORDER BY waiting_backends DESC, wait_event;

SELECT
    name,
    setting,
    unit,
    source,
    pending_restart
FROM pg_settings
WHERE name IN (
    'wal_buffers',
    'min_wal_size',
    'max_wal_size',
    'checkpoint_timeout',
    'checkpoint_completion_target',
    'wal_compression',
    'track_wal_io_timing',
    'archive_mode',
    'archive_timeout'
)
ORDER BY name;

-- SAMPLE_OUTPUT_BEGIN
-- wal_bytes_pretty | wal_buffers_full | slot_retained_wal_pretty | average_wal_sync_ms | diagnosis
-- source_view | requested_checkpoint_pct | checkpoint_write_time_ms | diagnosis
-- SAMPLE_OUTPUT_END
