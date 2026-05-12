/*
PostgreSQL DBA Script: WAL Writer Archiver Pressure
Purpose: Diagnose WAL writer and archiver pressure that can manifest as high IO/CPU latency.
Area: Background Processes and Memory Pressure
Usage: Run on primary. Review wal_buffers_full and archive failures.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
DROP TABLE IF EXISTS pg_temp.wal_writer_archiver_pressure_result;
CREATE TEMP TABLE pg_temp.wal_writer_archiver_pressure_result (
    wal_records bigint,
    wal_fpi bigint,
    wal_generated_gb numeric,
    wal_buffers_full bigint,
    wal_write bigint,
    wal_sync bigint,
    wal_write_time_ms numeric,
    wal_sync_time_ms numeric,
    avg_wal_io_time_ms numeric,
    archived_count bigint,
    failed_count bigint,
    last_archived_time timestamptz,
    last_failed_time timestamptz,
    archive_failure_pct numeric,
    pressure_label text,
    wal_stats_reset timestamptz,
    archiver_stats_reset timestamptz
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
            INSERT INTO pg_temp.wal_writer_archiver_pressure_result
            SELECT
                w.wal_records,
                w.wal_fpi,
                round(w.wal_bytes / 1024.0 / 1024.0 / 1024.0, 2),
                w.wal_buffers_full,
                w.wal_write,
                w.wal_sync,
                round(coalesce(w.wal_write_time, 0)::numeric, 2),
                round(coalesce(w.wal_sync_time, 0)::numeric, 2),
                round(
                    CASE WHEN coalesce(w.wal_write, 0) + coalesce(w.wal_sync, 0) = 0 THEN 0
                         ELSE (coalesce(w.wal_write_time, 0) + coalesce(w.wal_sync_time, 0))::numeric
                              / (coalesce(w.wal_write, 0) + coalesce(w.wal_sync, 0))
                    END,
                    4
                ),
                a.archived_count,
                a.failed_count,
                a.last_archived_time,
                a.last_failed_time,
                round(
                    CASE WHEN a.archived_count + a.failed_count = 0 THEN 0
                         ELSE 100.0 * a.failed_count::numeric / (a.archived_count + a.failed_count)
                    END,
                    2
                ),
                CASE
                    WHEN a.failed_count > 0 AND a.last_failed_time > clock_timestamp() - interval '1 hour' THEN 'ARCHIVE_FAILURE_PRESSURE'
                    WHEN w.wal_buffers_full > 0 THEN 'WAL_BUFFER_CONTENTION'
                    WHEN coalesce(w.wal_sync_time, 0) > coalesce(w.wal_write_time, 0) * 2 THEN 'FSYNC_DOMINATED_WAL_IO'
                    ELSE 'NO_STRONG_WAL_PRESSURE_SIGNAL'
                END,
                w.stats_reset,
                a.stats_reset
            FROM pg_stat_wal w
            CROSS JOIN pg_stat_archiver a
        $sql$;
    ELSE
        INSERT INTO pg_temp.wal_writer_archiver_pressure_result
        SELECT
            w.wal_records,
            w.wal_fpi,
            round(w.wal_bytes / 1024.0 / 1024.0 / 1024.0, 2),
            w.wal_buffers_full,
            NULL::bigint,
            NULL::bigint,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            a.archived_count,
            a.failed_count,
            a.last_archived_time,
            a.last_failed_time,
            round(
                CASE WHEN a.archived_count + a.failed_count = 0 THEN 0
                     ELSE 100.0 * a.failed_count::numeric / (a.archived_count + a.failed_count)
                END,
                2
            ),
            CASE
                WHEN a.failed_count > 0 AND a.last_failed_time > clock_timestamp() - interval '1 hour' THEN 'ARCHIVE_FAILURE_PRESSURE'
                WHEN w.wal_buffers_full > 0 THEN 'WAL_BUFFER_CONTENTION'
                ELSE 'NO_STRONG_WAL_PRESSURE_SIGNAL'
            END,
            w.stats_reset,
            a.stats_reset
        FROM pg_stat_wal w
        CROSS JOIN pg_stat_archiver a;
    END IF;
END;
$$;

SELECT *
FROM pg_temp.wal_writer_archiver_pressure_result;




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
