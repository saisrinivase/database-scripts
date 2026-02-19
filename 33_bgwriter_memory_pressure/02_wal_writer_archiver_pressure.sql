/*
Purpose: Diagnose WAL writer and archiver pressure that can manifest as high IO/CPU latency.
Area: Background Processes and Memory Pressure
Usage: Run on primary. Review wal_buffers_full and archive failures.
*/
SELECT EXISTS (
           SELECT 1
           FROM information_schema.columns
           WHERE table_schema = 'pg_catalog'
             AND table_name = 'pg_stat_wal'
             AND column_name = 'wal_write_time'
       ) AS has_wal_timing_cols
\gset

\if :has_wal_timing_cols
WITH wal AS (
    SELECT
        wal_records,
        wal_fpi,
        wal_bytes,
        wal_buffers_full,
        wal_write,
        wal_sync,
        wal_write_time,
        wal_sync_time,
        stats_reset
    FROM pg_stat_wal
),
arch AS (
    SELECT
        archived_count,
        failed_count,
        last_archived_time,
        last_failed_time,
        stats_reset
    FROM pg_stat_archiver
)
SELECT
    wal_records,
    wal_fpi,
    round(wal_bytes / 1024.0 / 1024.0 / 1024.0, 2) AS wal_generated_gb,
    wal_buffers_full,
    wal_write,
    wal_sync,
    round(coalesce(wal_write_time, 0)::numeric, 2) AS wal_write_time_ms,
    round(coalesce(wal_sync_time, 0)::numeric, 2) AS wal_sync_time_ms,
    round(
        CASE WHEN coalesce(wal_write, 0) + coalesce(wal_sync, 0) = 0 THEN 0
             ELSE (coalesce(wal_write_time, 0) + coalesce(wal_sync_time, 0))::numeric / (coalesce(wal_write, 0) + coalesce(wal_sync, 0))
        END,
        4
    ) AS avg_wal_io_time_ms,
    archived_count,
    failed_count,
    last_archived_time,
    last_failed_time,
    round(
        CASE WHEN archived_count + failed_count = 0 THEN 0
             ELSE 100.0 * failed_count::numeric / (archived_count + failed_count)
        END,
        2
    ) AS archive_failure_pct,
    CASE
        WHEN failed_count > 0 AND last_failed_time > clock_timestamp() - interval '1 hour' THEN 'ARCHIVE_FAILURE_PRESSURE'
        WHEN wal_buffers_full > 0 THEN 'WAL_BUFFER_CONTENTION'
        WHEN coalesce(wal_sync_time, 0) > coalesce(wal_write_time, 0) * 2 THEN 'FSYNC_DOMINATED_WAL_IO'
        ELSE 'NO_STRONG_WAL_PRESSURE_SIGNAL'
    END AS pressure_label,
    wal.stats_reset AS wal_stats_reset,
    arch.stats_reset AS archiver_stats_reset
FROM wal
CROSS JOIN arch;
\else
WITH wal AS (
    SELECT
        wal_records,
        wal_fpi,
        wal_bytes,
        wal_buffers_full,
        stats_reset
    FROM pg_stat_wal
),
arch AS (
    SELECT
        archived_count,
        failed_count,
        last_archived_time,
        last_failed_time,
        stats_reset
    FROM pg_stat_archiver
)
SELECT
    wal_records,
    wal_fpi,
    round(wal_bytes / 1024.0 / 1024.0 / 1024.0, 2) AS wal_generated_gb,
    wal_buffers_full,
    NULL::bigint AS wal_write,
    NULL::bigint AS wal_sync,
    NULL::numeric AS wal_write_time_ms,
    NULL::numeric AS wal_sync_time_ms,
    NULL::numeric AS avg_wal_io_time_ms,
    archived_count,
    failed_count,
    last_archived_time,
    last_failed_time,
    round(
        CASE WHEN archived_count + failed_count = 0 THEN 0
             ELSE 100.0 * failed_count::numeric / (archived_count + failed_count)
        END,
        2
    ) AS archive_failure_pct,
    CASE
        WHEN failed_count > 0 AND last_failed_time > clock_timestamp() - interval '1 hour' THEN 'ARCHIVE_FAILURE_PRESSURE'
        WHEN wal_buffers_full > 0 THEN 'WAL_BUFFER_CONTENTION'
        ELSE 'NO_STRONG_WAL_PRESSURE_SIGNAL'
    END AS pressure_label,
    wal.stats_reset AS wal_stats_reset,
    arch.stats_reset AS archiver_stats_reset
FROM wal
CROSS JOIN arch;
\endif




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh2
--
--  wal_records | wal_fpi | wal_generated_gb | wal_buffers_full | wal_write | wal_sync | wal_write_time_ms | wal_sync_time_ms | avg_wal_io_time_ms | archived_count | failed_count | last_archived_time | last_failed_time | archive_failure_pct |    pressure_label     |        wal_stats_reset        |     archiver_stats_reset      
-- -------------+---------+------------------+------------------+-----------+----------+-------------------+------------------+--------------------+----------------+--------------+--------------------+------------------+---------------------+-----------------------+-------------------------------+-------------------------------
--     90317348 |  699084 |            32.78 |          2862931 |           |          |                   |                  |                    |              0 |            0 |                    |                  |                0.00 | WAL_BUFFER_CONTENTION | 2026-01-31 20:40:48.109778-05 | 2026-01-31 20:40:48.109778-05
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
