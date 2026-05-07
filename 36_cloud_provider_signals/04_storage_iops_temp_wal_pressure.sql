/*
PostgreSQL DBA Script: Storage Iops Temp WAL Pressure
Purpose: Summarize storage/IO pressure signals often correlated with cloud IOPS or burst-balance incidents.
Area: Cloud Provider Signals
Usage: Use during incident windows to correlate spikes in read/write/temp/WAL activity.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
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
WITH db AS (
    SELECT
        datname,
        blks_read,
        blks_hit,
        temp_files,
        temp_bytes,
        blk_read_time,
        blk_write_time,
        stats_reset
    FROM pg_stat_database
    WHERE datname = current_database()
),
wal AS (
    SELECT
        wal_records,
        wal_fpi,
        wal_bytes,
        wal_buffers_full,
        wal_write_time,
        wal_sync_time,
        stats_reset
    FROM pg_stat_wal
)
SELECT
    d.datname AS database_name,
    d.blks_read,
    d.blks_hit,
    round(
        CASE WHEN d.blks_read + d.blks_hit = 0 THEN 0
             ELSE 100.0 * d.blks_hit::numeric / (d.blks_read + d.blks_hit)
        END,
        2
    ) AS cache_hit_pct,
    d.temp_files,
    pg_size_pretty(d.temp_bytes) AS temp_bytes_pretty,
    round(coalesce(d.blk_read_time, 0)::numeric, 2) AS blk_read_time_ms,
    round(coalesce(d.blk_write_time, 0)::numeric, 2) AS blk_write_time_ms,
    round(w.wal_bytes / 1024.0 / 1024.0 / 1024.0, 2) AS wal_generated_gb,
    w.wal_buffers_full,
    round(coalesce(w.wal_write_time, 0)::numeric, 2) AS wal_write_time_ms,
    round(coalesce(w.wal_sync_time, 0)::numeric, 2) AS wal_sync_time_ms,
    CASE
        WHEN d.temp_bytes > 5::bigint * 1024 * 1024 * 1024 THEN 'TEMP_SPILL_PRESSURE'
        WHEN coalesce(d.blk_read_time, 0) > coalesce(d.blk_write_time, 0) * 2 THEN 'READ_IO_LATENCY_PRESSURE'
        WHEN w.wal_buffers_full > 0 THEN 'WAL_BUFFER_PRESSURE'
        ELSE 'NO_STRONG_STORAGE_PRESSURE_SIGNAL'
    END AS pressure_label,
    d.stats_reset AS db_stats_reset,
    w.stats_reset AS wal_stats_reset
FROM db d
CROSS JOIN wal w;
\else
WITH db AS (
    SELECT
        datname,
        blks_read,
        blks_hit,
        temp_files,
        temp_bytes,
        blk_read_time,
        blk_write_time,
        stats_reset
    FROM pg_stat_database
    WHERE datname = current_database()
),
wal AS (
    SELECT
        wal_records,
        wal_fpi,
        wal_bytes,
        wal_buffers_full,
        stats_reset
    FROM pg_stat_wal
)
SELECT
    d.datname AS database_name,
    d.blks_read,
    d.blks_hit,
    round(
        CASE WHEN d.blks_read + d.blks_hit = 0 THEN 0
             ELSE 100.0 * d.blks_hit::numeric / (d.blks_read + d.blks_hit)
        END,
        2
    ) AS cache_hit_pct,
    d.temp_files,
    pg_size_pretty(d.temp_bytes) AS temp_bytes_pretty,
    round(coalesce(d.blk_read_time, 0)::numeric, 2) AS blk_read_time_ms,
    round(coalesce(d.blk_write_time, 0)::numeric, 2) AS blk_write_time_ms,
    round(w.wal_bytes / 1024.0 / 1024.0 / 1024.0, 2) AS wal_generated_gb,
    w.wal_buffers_full,
    NULL::numeric AS wal_write_time_ms,
    NULL::numeric AS wal_sync_time_ms,
    CASE
        WHEN d.temp_bytes > 5::bigint * 1024 * 1024 * 1024 THEN 'TEMP_SPILL_PRESSURE'
        WHEN coalesce(d.blk_read_time, 0) > coalesce(d.blk_write_time, 0) * 2 THEN 'READ_IO_LATENCY_PRESSURE'
        WHEN w.wal_buffers_full > 0 THEN 'WAL_BUFFER_PRESSURE'
        ELSE 'NO_STRONG_STORAGE_PRESSURE_SIGNAL'
    END AS pressure_label,
    d.stats_reset AS db_stats_reset,
    w.stats_reset AS wal_stats_reset
FROM db d
CROSS JOIN wal w;
\endif




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh2
--
--  database_name | blks_read | blks_hit  | cache_hit_pct | temp_files | temp_bytes_pretty | blk_read_time_ms | blk_write_time_ms | wal_generated_gb | wal_buffers_full | wal_write_time_ms | wal_sync_time_ms |   pressure_label    | db_stats_reset |        wal_stats_reset        
-- ---------------+-----------+-----------+---------------+------------+-------------------+------------------+-------------------+------------------+------------------+-------------------+------------------+---------------------+----------------+-------------------------------
--  pgbench_test  |  23919894 | 290995507 |         92.40 |        111 | 4164 MB           |             0.00 |              0.00 |            32.78 |          2862931 |                   |                  | WAL_BUFFER_PRESSURE |                | 2026-01-31 20:40:48.109778-05
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
