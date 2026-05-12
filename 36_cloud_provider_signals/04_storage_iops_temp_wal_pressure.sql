/*
PostgreSQL DBA Script: Storage Iops Temp WAL Pressure
Purpose: Summarize storage/IO pressure signals often correlated with cloud IOPS or burst-balance incidents.
Area: Cloud Provider Signals
Usage: Use during incident windows to correlate spikes in read/write/temp/WAL activity.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
DROP TABLE IF EXISTS pg_temp.storage_iops_temp_wal_pressure_result;
CREATE TEMP TABLE pg_temp.storage_iops_temp_wal_pressure_result (
    database_name name,
    blks_read bigint,
    blks_hit bigint,
    cache_hit_pct numeric,
    temp_files bigint,
    temp_bytes_pretty text,
    blk_read_time_ms numeric,
    blk_write_time_ms numeric,
    wal_generated_gb numeric,
    wal_buffers_full bigint,
    wal_write_time_ms numeric,
    wal_sync_time_ms numeric,
    pressure_label text,
    db_stats_reset timestamptz,
    wal_stats_reset timestamptz
);

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'pg_catalog'
          AND table_name = 'pg_stat_wal'
          AND column_name = 'wal_write_time'
    ) THEN
        EXECUTE $sql$
            INSERT INTO pg_temp.storage_iops_temp_wal_pressure_result
            SELECT
                d.datname,
                d.blks_read,
                d.blks_hit,
                round(
                    CASE WHEN d.blks_read + d.blks_hit = 0 THEN 0
                         ELSE 100.0 * d.blks_hit::numeric / (d.blks_read + d.blks_hit)
                    END,
                    2
                ),
                d.temp_files,
                pg_size_pretty(d.temp_bytes),
                round(coalesce(d.blk_read_time, 0)::numeric, 2),
                round(coalesce(d.blk_write_time, 0)::numeric, 2),
                round(w.wal_bytes / 1024.0 / 1024.0 / 1024.0, 2),
                w.wal_buffers_full,
                round(coalesce(w.wal_write_time, 0)::numeric, 2),
                round(coalesce(w.wal_sync_time, 0)::numeric, 2),
                CASE
                    WHEN d.temp_bytes > 5::bigint * 1024 * 1024 * 1024 THEN 'TEMP_SPILL_PRESSURE'
                    WHEN coalesce(d.blk_read_time, 0) > coalesce(d.blk_write_time, 0) * 2 THEN 'READ_IO_LATENCY_PRESSURE'
                    WHEN w.wal_buffers_full > 0 THEN 'WAL_BUFFER_PRESSURE'
                    ELSE 'NO_STRONG_STORAGE_PRESSURE_SIGNAL'
                END,
                d.stats_reset,
                w.stats_reset
            FROM pg_stat_database d
            CROSS JOIN pg_stat_wal w
            WHERE d.datname = current_database()
        $sql$;
    ELSE
        INSERT INTO pg_temp.storage_iops_temp_wal_pressure_result
        SELECT
            d.datname,
            d.blks_read,
            d.blks_hit,
            round(
                CASE WHEN d.blks_read + d.blks_hit = 0 THEN 0
                     ELSE 100.0 * d.blks_hit::numeric / (d.blks_read + d.blks_hit)
                END,
                2
            ),
            d.temp_files,
            pg_size_pretty(d.temp_bytes),
            round(coalesce(d.blk_read_time, 0)::numeric, 2),
            round(coalesce(d.blk_write_time, 0)::numeric, 2),
            round(w.wal_bytes / 1024.0 / 1024.0 / 1024.0, 2),
            w.wal_buffers_full,
            NULL::numeric,
            NULL::numeric,
            CASE
                WHEN d.temp_bytes > 5::bigint * 1024 * 1024 * 1024 THEN 'TEMP_SPILL_PRESSURE'
                WHEN coalesce(d.blk_read_time, 0) > coalesce(d.blk_write_time, 0) * 2 THEN 'READ_IO_LATENCY_PRESSURE'
                WHEN w.wal_buffers_full > 0 THEN 'WAL_BUFFER_PRESSURE'
                ELSE 'NO_STRONG_STORAGE_PRESSURE_SIGNAL'
            END,
            d.stats_reset,
            w.stats_reset
        FROM pg_stat_database d
        CROSS JOIN pg_stat_wal w
        WHERE d.datname = current_database();
    END IF;
END;
$$;

SELECT *
FROM pg_temp.storage_iops_temp_wal_pressure_result;




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
