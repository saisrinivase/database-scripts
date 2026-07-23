/*
PostgreSQL DBA Script: Checkpoint Background Writer Pressure 15 Plus
Purpose: Normalize PostgreSQL 15/16 and 17+ checkpoint/bgwriter statistics into one pressure report.
Area: Internals Deep Dive
Usage: Run in pgAdmin Query Tool or psql. Compare two executions during an incident for precise interval rates.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom for a representative result shape.
Notes: Uses a temporary function and dynamic SQL so missing version-specific views are never parsed. No permanent objects are created.
*/
CREATE OR REPLACE FUNCTION pg_temp.checkpoint_bgwriter_pressure_15_plus()
RETURNS TABLE (
    metric_name text,
    metric_value numeric,
    unit text,
    source_view text,
    stats_reset timestamptz,
    average_per_second numeric,
    status text,
    diagnosis text,
    recommended_action text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_checkpointer') IS NOT NULL THEN
        RETURN QUERY EXECUTE $query$
            WITH cp AS (
                SELECT
                    num_timed::numeric,
                    num_requested::numeric,
                    write_time::numeric,
                    sync_time::numeric,
                    buffers_written::numeric,
                    stats_reset,
                    greatest(extract(epoch FROM clock_timestamp() - stats_reset), 1)::numeric AS age_seconds
                FROM pg_stat_checkpointer
            ),
            bg AS (
                SELECT
                    buffers_clean::numeric,
                    maxwritten_clean::numeric,
                    buffers_alloc::numeric,
                    stats_reset,
                    greatest(extract(epoch FROM clock_timestamp() - stats_reset), 1)::numeric AS age_seconds
                FROM pg_stat_bgwriter
            )
            SELECT
                'checkpoints.requested_pct',
                round(100.0 * num_requested / NULLIF(num_timed + num_requested, 0), 2),
                'percent',
                'pg_stat_checkpointer',
                stats_reset,
                NULL::numeric,
                CASE WHEN 100.0 * num_requested / NULLIF(num_timed + num_requested, 0) >= 20 THEN 'WARN' ELSE 'OK' END,
                'Requested checkpoints are usually caused by WAL volume reaching configured limits.',
                'Review max_wal_size, checkpoint_timeout, WAL generation rate, and storage latency.'
            FROM cp
            UNION ALL
            SELECT
                'checkpoints.average_write_ms',
                round(write_time / NULLIF(num_timed + num_requested, 0), 3),
                'milliseconds_per_checkpoint',
                'pg_stat_checkpointer',
                stats_reset,
                NULL::numeric,
                CASE WHEN write_time / NULLIF(num_timed + num_requested, 0) >= 30000 THEN 'WARN' ELSE 'INFO' END,
                'Long checkpoint write duration can increase dirty-buffer pressure and overlap the next checkpoint.',
                'Correlate with pg_stat_io, provider storage latency, and checkpoint_completion_target.'
            FROM cp
            UNION ALL
            SELECT
                'checkpoints.average_sync_ms',
                round(sync_time / NULLIF(num_timed + num_requested, 0), 3),
                'milliseconds_per_checkpoint',
                'pg_stat_checkpointer',
                stats_reset,
                NULL::numeric,
                CASE WHEN sync_time / NULLIF(num_timed + num_requested, 0) >= 1000 THEN 'WARN' ELSE 'INFO' END,
                'Checkpoint sync time measures time spent making dirty files durable.',
                'Investigate storage fsync latency and checkpoint write bursts.'
            FROM cp
            UNION ALL
            SELECT
                'checkpoints.buffers_written',
                buffers_written,
                'buffers',
                'pg_stat_checkpointer',
                stats_reset,
                round(buffers_written / age_seconds, 4),
                'INFO',
                'Buffers written by the checkpointer since reset.',
                'Use the per-second average only as a baseline; interval deltas are more precise.'
            FROM cp
            UNION ALL
            SELECT
                'bgwriter.buffers_clean',
                buffers_clean,
                'buffers',
                'pg_stat_bgwriter',
                stats_reset,
                round(buffers_clean / age_seconds, 4),
                'INFO',
                'Buffers proactively written by the background writer.',
                'Compare with client-backend writes in pg_stat_io on PostgreSQL 16+.'
            FROM bg
            UNION ALL
            SELECT
                'bgwriter.maxwritten_clean',
                maxwritten_clean,
                'events',
                'pg_stat_bgwriter',
                stats_reset,
                round(maxwritten_clean / age_seconds, 6),
                CASE WHEN maxwritten_clean / age_seconds >= 0.01 THEN 'WARN' ELSE 'INFO' END,
                'The background writer stopped after reaching its configured page limit.',
                'Review bgwriter_lru_maxpages, bgwriter_lru_multiplier, allocation rate, and checkpoint pressure.'
            FROM bg
            UNION ALL
            SELECT
                'bgwriter.buffers_alloc',
                buffers_alloc,
                'buffers',
                'pg_stat_bgwriter',
                stats_reset,
                round(buffers_alloc / age_seconds, 4),
                'INFO',
                'Shared-buffer allocation activity since reset.',
                'A high interval rate with backend writes can indicate dirty-buffer replacement pressure.'
            FROM bg
        $query$;
    ELSE
        RETURN QUERY EXECUTE $query$
            WITH bg AS (
                SELECT
                    checkpoints_timed::numeric,
                    checkpoints_req::numeric,
                    checkpoint_write_time::numeric,
                    checkpoint_sync_time::numeric,
                    buffers_checkpoint::numeric,
                    buffers_clean::numeric,
                    maxwritten_clean::numeric,
                    buffers_backend::numeric,
                    buffers_backend_fsync::numeric,
                    buffers_alloc::numeric,
                    stats_reset,
                    greatest(extract(epoch FROM clock_timestamp() - stats_reset), 1)::numeric AS age_seconds
                FROM pg_stat_bgwriter
            )
            SELECT
                'checkpoints.requested_pct',
                round(100.0 * checkpoints_req / NULLIF(checkpoints_timed + checkpoints_req, 0), 2),
                'percent',
                'pg_stat_bgwriter',
                stats_reset,
                NULL::numeric,
                CASE WHEN 100.0 * checkpoints_req / NULLIF(checkpoints_timed + checkpoints_req, 0) >= 20 THEN 'WARN' ELSE 'OK' END,
                'Requested checkpoints are usually caused by WAL volume reaching configured limits.',
                'Review max_wal_size, checkpoint_timeout, WAL generation rate, and storage latency.'
            FROM bg
            UNION ALL
            SELECT 'checkpoints.average_write_ms',
                   round(checkpoint_write_time / NULLIF(checkpoints_timed + checkpoints_req, 0), 3),
                   'milliseconds_per_checkpoint', 'pg_stat_bgwriter', stats_reset, NULL::numeric,
                   CASE WHEN checkpoint_write_time / NULLIF(checkpoints_timed + checkpoints_req, 0) >= 30000 THEN 'WARN' ELSE 'INFO' END,
                   'Long checkpoint write duration can increase dirty-buffer pressure.',
                   'Correlate with storage latency and checkpoint_completion_target.'
            FROM bg
            UNION ALL
            SELECT 'checkpoints.average_sync_ms',
                   round(checkpoint_sync_time / NULLIF(checkpoints_timed + checkpoints_req, 0), 3),
                   'milliseconds_per_checkpoint', 'pg_stat_bgwriter', stats_reset, NULL::numeric,
                   CASE WHEN checkpoint_sync_time / NULLIF(checkpoints_timed + checkpoints_req, 0) >= 1000 THEN 'WARN' ELSE 'INFO' END,
                   'Checkpoint sync time measures time spent making dirty files durable.',
                   'Investigate storage fsync latency and write bursts.'
            FROM bg
            UNION ALL
            SELECT 'checkpoints.buffers_written', buffers_checkpoint, 'buffers', 'pg_stat_bgwriter', stats_reset,
                   round(buffers_checkpoint / age_seconds, 4), 'INFO',
                   'Buffers written by checkpoints since reset.',
                   'Use interval deltas for incident analysis.'
            FROM bg
            UNION ALL
            SELECT 'bgwriter.buffers_clean', buffers_clean, 'buffers', 'pg_stat_bgwriter', stats_reset,
                   round(buffers_clean / age_seconds, 4), 'INFO',
                   'Buffers proactively written by the background writer.',
                   'Compare with backend write fallback.'
            FROM bg
            UNION ALL
            SELECT 'bgwriter.maxwritten_clean', maxwritten_clean, 'events', 'pg_stat_bgwriter', stats_reset,
                   round(maxwritten_clean / age_seconds, 6),
                   CASE WHEN maxwritten_clean / age_seconds >= 0.01 THEN 'WARN' ELSE 'INFO' END,
                   'The background writer stopped after reaching its configured page limit.',
                   'Review bgwriter settings, allocation rate, and checkpoint pressure.'
            FROM bg
            UNION ALL
            SELECT 'backend.buffers_written', buffers_backend, 'buffers', 'pg_stat_bgwriter', stats_reset,
                   round(buffers_backend / age_seconds, 4),
                   CASE WHEN buffers_backend > buffers_clean THEN 'WARN' ELSE 'INFO' END,
                   'Client backends had to write dirty buffers themselves.',
                   'Backend write dominance can add query latency; tune bgwriter/checkpoints and investigate storage.'
            FROM bg
            UNION ALL
            SELECT 'backend.fsync_calls', buffers_backend_fsync, 'events', 'pg_stat_bgwriter', stats_reset,
                   round(buffers_backend_fsync / age_seconds, 6),
                   CASE WHEN buffers_backend_fsync > 0 THEN 'WARN' ELSE 'OK' END,
                   'Client backends issued their own fsync calls.',
                   'Any recurring backend fsync requires storage and checkpoint investigation.'
            FROM bg
        $query$;
    END IF;
END;
$$;

SELECT *
FROM pg_temp.checkpoint_bgwriter_pressure_15_plus()
ORDER BY
    CASE status WHEN 'WARN' THEN 1 WHEN 'OK' THEN 2 ELSE 3 END,
    metric_name;

-- Current waits provide the live evidence that cumulative counters cannot.
SELECT
    backend_type,
    wait_event_type,
    wait_event,
    count(*) AS waiting_backends,
    max(clock_timestamp() - query_start) AS longest_query_age,
    string_agg(DISTINCT regexp_replace(query, '\s+', ' ', 'g'), E'\n') AS complete_query_texts
FROM pg_stat_activity
WHERE wait_event_type IN ('IO', 'LWLock')
  AND (
      wait_event ILIKE '%buffer%'
      OR wait_event ILIKE '%checkpoint%'
      OR wait_event ILIKE '%datafile%'
      OR wait_event ILIKE '%wal%'
  )
GROUP BY backend_type, wait_event_type, wait_event
ORDER BY waiting_backends DESC, wait_event;

-- SAMPLE_OUTPUT_BEGIN
-- metric_name                    | metric_value | unit       | status | diagnosis
-- checkpoints.requested_pct      | 4.25         | percent    | OK     | Requested checkpoints...
-- bgwriter.maxwritten_clean      | 12           | events     | INFO   | The background writer...
-- SAMPLE_OUTPUT_END
