/*
PostgreSQL DBA Script: AWS Disk Queue Depth Deep Dive
Purpose: Diagnose DiskQueueDepth and DiskQueueDepthLogVolume spikes using live I/O waits, PostgreSQL I/O timing, WAL, checkpoints, temp spills, and high-I/O SQL.
Area: AWS RDS and Aurora PostgreSQL
Usage: Run while queue depth is elevated and compare the same DB instance, storage volume, and CloudWatch period.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only except for a session-local pg_temp function. Queue depth is an AWS storage metric and has no exact PostgreSQL SQL equivalent.
*/
SELECT
    backend_type,
    wait_event_type,
    wait_event,
    count(*) AS waiting_backends,
    round(100.0 * count(*) / NULLIF(sum(count(*)) OVER (), 0), 2) AS pct_of_io_waiters,
    max(clock_timestamp() - query_start) AS longest_query_age,
    string_agg(DISTINCT regexp_replace(query, '\s+', ' ', 'g'), E'\n') AS complete_query_texts,
    CASE
        WHEN wait_event ILIKE '%wal%' THEN 'LOG_VOLUME_OR_WAL_PATH'
        WHEN wait_event ILIKE '%temp%' THEN 'LOCAL_TEMP_STORAGE'
        WHEN wait_event ILIKE '%datafile%' THEN 'DATABASE_STORAGE'
        WHEN wait_event ILIKE '%slru%' THEN 'SLRU_CONTROL_STORAGE'
        ELSE 'CLASSIFY_EXACT_IO_WAIT'
    END AS likely_storage_path
FROM pg_stat_activity
WHERE wait_event_type = 'IO'
   OR wait_event ILIKE '%datafile%'
   OR wait_event ILIKE '%wal%'
   OR wait_event ILIKE '%temp%'
   OR wait_event ILIKE '%slru%'
GROUP BY backend_type, wait_event_type, wait_event
ORDER BY waiting_backends DESC, longest_query_age DESC NULLS LAST;

CREATE OR REPLACE FUNCTION pg_temp.aws_queue_pg_stat_io()
RETURNS TABLE (
    backend_type text,
    object_name text,
    context_name text,
    reads numeric,
    average_read_ms numeric,
    writes numeric,
    average_write_ms numeric,
    fsyncs numeric,
    average_fsync_ms numeric,
    evictions numeric,
    diagnosis text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_io') IS NULL THEN
        RETURN;
    END IF;

    RETURN QUERY EXECUTE $query$
        SELECT
            backend_type,
            object,
            context,
            coalesce((to_jsonb(i)->>'reads')::numeric, 0),
            round(coalesce((to_jsonb(i)->>'read_time')::numeric, 0)
                / NULLIF((to_jsonb(i)->>'reads')::numeric, 0), 3),
            coalesce((to_jsonb(i)->>'writes')::numeric, 0),
            round(coalesce((to_jsonb(i)->>'write_time')::numeric, 0)
                / NULLIF((to_jsonb(i)->>'writes')::numeric, 0), 3),
            coalesce((to_jsonb(i)->>'fsyncs')::numeric, 0),
            round(coalesce((to_jsonb(i)->>'fsync_time')::numeric, 0)
                / NULLIF((to_jsonb(i)->>'fsyncs')::numeric, 0), 3),
            coalesce((to_jsonb(i)->>'evictions')::numeric, 0),
            CASE
                WHEN coalesce((to_jsonb(i)->>'fsync_time')::numeric, 0)
                     / NULLIF((to_jsonb(i)->>'fsyncs')::numeric, 0) >= 10 THEN 'HIGH_FSYNC_LATENCY_BUCKET'
                WHEN coalesce((to_jsonb(i)->>'read_time')::numeric, 0)
                     / NULLIF((to_jsonb(i)->>'reads')::numeric, 0) >= 10 THEN 'HIGH_READ_LATENCY_BUCKET'
                WHEN coalesce((to_jsonb(i)->>'write_time')::numeric, 0)
                     / NULLIF((to_jsonb(i)->>'writes')::numeric, 0) >= 10 THEN 'HIGH_WRITE_LATENCY_BUCKET'
                ELSE 'COMPARE_INTERVAL_DELTA_WITH_QUEUE_SPIKE'
            END
        FROM pg_stat_io i
        ORDER BY
            coalesce((to_jsonb(i)->>'read_time')::numeric, 0)
          + coalesce((to_jsonb(i)->>'write_time')::numeric, 0)
          + coalesce((to_jsonb(i)->>'fsync_time')::numeric, 0) DESC
    $query$;
END;
$$;

SELECT * FROM pg_temp.aws_queue_pg_stat_io();

WITH wal AS (
    SELECT
        coalesce(NULLIF(to_jsonb(w)->>'wal_bytes', '')::numeric, 0) AS wal_bytes,
        coalesce(NULLIF(to_jsonb(w)->>'wal_buffers_full', '')::numeric, 0) AS wal_buffers_full,
        NULLIF(to_jsonb(w)->>'wal_write', '')::numeric AS wal_write,
        NULLIF(to_jsonb(w)->>'wal_sync', '')::numeric AS wal_sync,
        NULLIF(to_jsonb(w)->>'wal_write_time', '')::numeric AS wal_write_time,
        NULLIF(to_jsonb(w)->>'wal_sync_time', '')::numeric AS wal_sync_time,
        NULLIF(to_jsonb(w)->>'stats_reset', '')::timestamptz AS stats_reset
    FROM pg_stat_wal w
)
SELECT
    wal_bytes,
    wal_buffers_full,
    wal_write,
    wal_sync,
    wal_write_time,
    wal_sync_time,
    round(wal_write_time / NULLIF(wal_write, 0), 3) AS average_wal_write_ms,
    round(wal_sync_time / NULLIF(wal_sync, 0), 3) AS average_wal_sync_ms,
    stats_reset,
    CASE
        WHEN wal_sync_time / NULLIF(wal_sync, 0) >= 10 THEN 'WAL_SYNC_LATENCY_CAN_DRIVE_LOG_QUEUE'
        WHEN wal_buffers_full > 0 THEN 'WAL_BUFFER_PRESSURE_EXISTS_COMPARE_DELTA'
        WHEN wal_write IS NULL THEN 'PG18_USE_PG_STAT_IO_WAL_ROWS_FOR_WRITE_AND_SYNC_TIMING'
        ELSE 'COMPARE_WAL_RATE_AND_CHECKPOINT_ACTIVITY_WITH_SPIKE'
    END AS diagnosis
FROM wal;

SELECT
    datname,
    temp_files,
    temp_bytes,
    pg_size_pretty(temp_bytes) AS temp_bytes_pretty,
    blk_read_time,
    blk_write_time,
    stats_reset,
    CASE
        WHEN temp_bytes >= 10::bigint * 1024 * 1024 * 1024 THEN 'TEMP_SPILL_VOLUME_CAN_DRIVE_LOCAL_QUEUE'
        WHEN blk_read_time + blk_write_time > 0 THEN 'DATABASE_IO_TIMING_VISIBLE_COMPARE_INTERVAL_DELTA'
        ELSE 'NO_CUMULATIVE_TIMING_EVIDENCE_OR_TIMING_DISABLED'
    END AS diagnosis
FROM pg_stat_database
WHERE datname IS NOT NULL
ORDER BY temp_bytes DESC, blk_read_time + blk_write_time DESC;

-- SAMPLE_OUTPUT_BEGIN
-- wait_event | waiting_backends | pct_of_io_waiters | complete_query_texts | likely_storage_path
-- backend_type | object_name | reads | average_read_ms | writes | average_write_ms | fsyncs | diagnosis
-- SAMPLE_OUTPUT_END
