/*
PostgreSQL DBA Script: WAL Write Path Pressure Dashboard
Purpose: Diagnose WAL generation, buffer exhaustion, write/sync latency, archiving, slot retention, and live WAL waits in one run.
Area: Internals Deep Dive
Usage: Run in pgAdmin Query Tool or psql on PostgreSQL 15+. Use repeated snapshots to calculate incident-window rates.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom for representative result shapes.
Notes: Read-only, extension-free, and cloud-safe. Cumulative counters must be interpreted with stats_reset and workload duration.
*/

-- Result 1: WAL counters normalized by uptime since the statistics reset.
WITH wal AS (
    SELECT
        w.wal_records::numeric,
        w.wal_fpi::numeric,
        w.wal_bytes::numeric,
        w.wal_buffers_full::numeric,
        coalesce((to_jsonb(w) ->> 'wal_write')::numeric, 0) AS wal_write,
        coalesce((to_jsonb(w) ->> 'wal_sync')::numeric, 0) AS wal_sync,
        coalesce((to_jsonb(w) ->> 'wal_write_time')::numeric, 0) AS wal_write_time,
        coalesce((to_jsonb(w) ->> 'wal_sync_time')::numeric, 0) AS wal_sync_time,
        (to_jsonb(w) ? 'wal_write') AS has_wal_operation_counts,
        w.stats_reset,
        greatest(extract(epoch FROM clock_timestamp() - w.stats_reset), 1)::numeric AS stats_age_seconds
    FROM pg_stat_wal w
)
SELECT
    stats_reset,
    round(stats_age_seconds, 0) AS stats_age_seconds,
    wal_records,
    wal_fpi,
    round(100.0 * wal_fpi / NULLIF(wal_records, 0), 2) AS full_page_image_pct,
    wal_bytes,
    pg_size_pretty(wal_bytes::bigint) AS wal_bytes_pretty,
    round(wal_bytes / stats_age_seconds, 2) AS average_wal_bytes_per_second,
    wal_buffers_full,
    round(wal_buffers_full / stats_age_seconds, 4) AS average_wal_buffers_full_per_second,
    wal_write,
    wal_sync,
    CASE WHEN has_wal_operation_counts
         THEN round(wal_write_time / NULLIF(wal_write, 0), 3)
    END AS average_wal_write_ms,
    CASE WHEN has_wal_operation_counts
         THEN round(wal_sync_time / NULLIF(wal_sync, 0), 3)
    END AS average_wal_sync_ms,
    CASE
        WHEN has_wal_operation_counts AND wal_sync_time / NULLIF(wal_sync, 0) >= 10
            THEN 'HIGH: average WAL sync latency is at least 10 ms.'
        WHEN has_wal_operation_counts AND wal_write_time / NULLIF(wal_write, 0) >= 10
            THEN 'HIGH: average WAL write latency is at least 10 ms.'
        WHEN wal_buffers_full / stats_age_seconds >= 0.1 THEN 'REVIEW: WAL buffers are filling repeatedly.'
        WHEN wal_buffers_full > 0 THEN 'Historical WAL buffer-full events exist; compare two snapshots for current rate.'
        WHEN NOT has_wal_operation_counts THEN 'WAL write/sync operation counts are not exposed by this server version; use pg_stat_io and provider latency metrics.'
        ELSE 'No obvious cumulative WAL write-path pressure.'
    END AS diagnosis,
    CASE
        WHEN has_wal_operation_counts AND wal_sync_time / NULLIF(wal_sync, 0) >= 10
            THEN 'Correlate with storage latency, synchronous_commit, replication waits, and checkpoint activity.'
        WHEN wal_buffers_full > 0 THEN 'Measure the delta, review wal_buffers, large transactions, checkpoint cadence, and WAL write latency.'
        WHEN NOT has_wal_operation_counts THEN 'Use 13_io_wal_checkpoints/07_pg_stat_io_overview_pg16_plus.sql and cloud storage metrics for write latency.'
        ELSE 'Capture a second snapshot during load; cumulative totals alone cannot identify a short incident.'
    END AS recommended_action
FROM wal;

-- Result 2: live sessions waiting in the WAL or replication write path.
SELECT
    a.pid,
    a.backend_type,
    a.usename,
    a.datname,
    a.application_name,
    a.state,
    clock_timestamp() - a.query_start AS query_age,
    a.wait_event_type,
    a.wait_event,
    regexp_replace(a.query, '\s+', ' ', 'g') AS query_text,
    CASE
        WHEN a.wait_event IN ('WALSync', 'WALWrite') THEN 'Local WAL write or sync path is delaying this backend.'
        WHEN a.wait_event LIKE 'SyncRep%' THEN 'Synchronous replication acknowledgement is delaying commit.'
        WHEN a.wait_event LIKE 'WalSender%' OR a.backend_type = 'walsender' THEN 'WAL sender or replication transport path is active.'
        ELSE 'WAL-related wait; correlate with pg_stat_wal, replication, and storage.'
    END AS diagnosis
FROM pg_stat_activity a
WHERE a.wait_event_type IS NOT NULL
  AND (
      a.wait_event ILIKE '%wal%'
      OR a.wait_event ILIKE '%syncrep%'
      OR a.backend_type IN ('walsender', 'walwriter')
  )
ORDER BY query_age DESC NULLS LAST;

-- Result 3: archiver health. On provider-managed archiving, provider metrics may be the authoritative source.
SELECT
    archived_count,
    failed_count,
    last_archived_wal,
    last_archived_time,
    last_failed_wal,
    last_failed_time,
    stats_reset,
    CASE
        WHEN current_setting('archive_mode') = 'off' THEN 'Archive mode is off; verify whether the platform provides another PITR mechanism.'
        WHEN failed_count > 0 AND last_failed_time >= coalesce(last_archived_time, '-infinity'::timestamptz)
            THEN 'CRITICAL: the latest visible archive attempt failed.'
        WHEN failed_count > 0 THEN 'Historical archive failures exist; confirm a newer successful archive.'
        ELSE 'No archive failure is visible in PostgreSQL statistics.'
    END AS diagnosis
FROM pg_stat_archiver;

-- Result 4: replication slots retaining WAL.
SELECT
    slot_name,
    slot_type,
    active,
    active_pid,
    restart_lsn,
    confirmed_flush_lsn,
    coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn), 0) AS retained_wal_bytes,
    pg_size_pretty(coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn), 0)) AS retained_wal_pretty,
    CASE
        WHEN NOT active AND coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn), 0) >= 10::numeric * 1024 * 1024 * 1024
            THEN 'CRITICAL: inactive slot retains at least 10 GB of WAL.'
        WHEN NOT active THEN 'REVIEW: inactive slot can retain WAL until it is consumed or removed.'
        WHEN coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn), 0) >= 10::numeric * 1024 * 1024 * 1024
            THEN 'HIGH: active consumer is significantly behind.'
        ELSE 'Slot retention is below the script review threshold.'
    END AS diagnosis,
    'Confirm consumer ownership and recovery requirements before changing or dropping a slot.' AS recommended_action
FROM pg_replication_slots
ORDER BY retained_wal_bytes DESC;

-- Result 5: settings that shape the WAL and checkpoint write path.
SELECT
    name,
    setting,
    unit,
    source,
    pending_restart,
    CASE name
        WHEN 'wal_buffers' THEN 'Buffers absorb WAL bursts before walwriter/backend flushes.'
        WHEN 'max_wal_size' THEN 'Low headroom can cause requested checkpoints during write bursts.'
        WHEN 'checkpoint_timeout' THEN 'Upper time interval between automatic checkpoints.'
        WHEN 'checkpoint_completion_target' THEN 'Spreads checkpoint writes across the checkpoint interval.'
        WHEN 'wal_compression' THEN 'Can reduce full-page-image WAL at the cost of CPU.'
        WHEN 'synchronous_commit' THEN 'Controls whether commits wait for local or remote durability.'
        WHEN 'archive_mode' THEN 'Enables continuous WAL archiving; managed platforms may implement the archive destination.'
        ELSE 'WAL write-path setting.'
    END AS purpose
FROM pg_settings
WHERE name IN (
    'wal_buffers',
    'min_wal_size',
    'max_wal_size',
    'checkpoint_timeout',
    'checkpoint_completion_target',
    'wal_compression',
    'synchronous_commit',
    'archive_mode',
    'archive_timeout'
)
ORDER BY name;

-- SAMPLE_OUTPUT_BEGIN
-- Result 1: wal_bytes_pretty | average_wal_bytes_per_second | average_wal_sync_ms | diagnosis
-- Result 2: pid | wait_event | query_text | diagnosis
-- Result 3: archived_count | failed_count | last_archived_time | diagnosis
-- Result 4: slot_name | active | retained_wal_pretty | diagnosis
-- Result 5: name | setting | source | purpose
-- SAMPLE_OUTPUT_END
