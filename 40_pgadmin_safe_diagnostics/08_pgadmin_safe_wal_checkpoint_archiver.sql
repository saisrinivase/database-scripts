/*
Purpose: pgAdmin-safe WAL, checkpoint, and archiver pressure dashboard.
Scope: WAL volume, WAL sync/write time, archive failures, checkpoint frequency, requested checkpoint ratio, and write pressure.
pgAdmin: Safe to run in Query Tool. Uses a temporary helper function only.
Sample output:
 component   | metric_name              | metric_value | unit    | diagnosis
-------------+--------------------------+--------------+---------+-----------------------------
 checkpoint  | requested_checkpoint_pct | 65.00        | percent | Increase max_wal_size review.
*/

CREATE OR REPLACE FUNCTION pg_temp.pgadmin_wal_checkpoint_archiver()
RETURNS TABLE (
    component text,
    metric_name text,
    metric_value numeric,
    unit text,
    source_view text,
    diagnosis text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_wal') IS NOT NULL THEN
        RETURN QUERY EXECUTE
        $sql$
            SELECT 'wal'::text, 'wal_records'::text, wal_records::numeric, 'count'::text, 'pg_stat_wal'::text,
                   'High record volume points to write-heavy workload or churn.'::text
            FROM pg_stat_wal
            UNION ALL
            SELECT 'wal', 'wal_bytes', wal_bytes::numeric, 'bytes', 'pg_stat_wal',
                   'WAL bytes since stats reset. Correlate with top WAL SQL and checkpoint pressure.'
            FROM pg_stat_wal
            UNION ALL
            SELECT 'wal', 'wal_buffers_full', wal_buffers_full::numeric, 'count', 'pg_stat_wal',
                   'WAL buffers full events indicate WAL insertion pressure or undersized wal_buffers.'
            FROM pg_stat_wal
        $sql$;
    END IF;

    RETURN QUERY
    SELECT 'archiver'::text, 'failed_count'::text, failed_count::numeric, 'count'::text, 'pg_stat_archiver'::text,
           CASE WHEN failed_count > 0 THEN 'Archive failures detected. PITR/WAL storage risk.' ELSE 'No archive failures since stats reset.' END::text
    FROM pg_stat_archiver
    UNION ALL
    SELECT 'archiver', 'archived_count', archived_count::numeric, 'count', 'pg_stat_archiver',
           'Archived WAL segments since stats reset.'
    FROM pg_stat_archiver;

    IF to_regclass('pg_catalog.pg_stat_checkpointer') IS NOT NULL THEN
        RETURN QUERY EXECUTE
        $sql$
            SELECT 'checkpoint'::text, 'requested_checkpoint_pct'::text,
                   round(100 * num_requested::numeric / NULLIF(num_timed + num_requested, 0), 2),
                   'percent'::text, 'pg_stat_checkpointer'::text,
                   CASE WHEN num_requested > num_timed THEN 'Requested checkpoints dominate. Review max_wal_size and checkpoint_timeout.'
                        ELSE 'Timed checkpoints dominate or pressure is low.' END::text
            FROM pg_stat_checkpointer
            UNION ALL
            SELECT 'checkpoint', 'checkpoint_write_time_ms', round(write_time::numeric, 2), 'ms', 'pg_stat_checkpointer',
                   'High write time indicates checkpoint I/O pressure.'
            FROM pg_stat_checkpointer
            UNION ALL
            SELECT 'checkpoint', 'checkpoint_sync_time_ms', round(sync_time::numeric, 2), 'ms', 'pg_stat_checkpointer',
                   'High sync time indicates storage/fsync pressure during checkpoints.'
            FROM pg_stat_checkpointer
        $sql$;
    ELSE
        RETURN QUERY EXECUTE
        $sql$
            SELECT 'checkpoint'::text, 'requested_checkpoint_pct'::text,
                   round(100 * checkpoints_req::numeric / NULLIF(checkpoints_timed + checkpoints_req, 0), 2),
                   'percent'::text, 'pg_stat_bgwriter'::text,
                   CASE WHEN checkpoints_req > checkpoints_timed THEN 'Requested checkpoints dominate. Review max_wal_size and checkpoint_timeout.'
                        ELSE 'Timed checkpoints dominate or pressure is low.' END::text
            FROM pg_stat_bgwriter
            UNION ALL
            SELECT 'checkpoint', 'checkpoint_write_time_ms', round(checkpoint_write_time::numeric, 2), 'ms', 'pg_stat_bgwriter',
                   'High write time indicates checkpoint I/O pressure.'
            FROM pg_stat_bgwriter
            UNION ALL
            SELECT 'checkpoint', 'checkpoint_sync_time_ms', round(checkpoint_sync_time::numeric, 2), 'ms', 'pg_stat_bgwriter',
                   'High sync time indicates storage/fsync pressure during checkpoints.'
            FROM pg_stat_bgwriter
        $sql$;
    END IF;
END;
$$;

SELECT *
FROM pg_temp.pgadmin_wal_checkpoint_archiver()
ORDER BY component, metric_name;

-- SAMPLE_OUTPUT_BEGIN
-- component  | metric_name              | metric_value | unit    | source_view          | diagnosis
-- -----------+--------------------------+--------------+---------+----------------------+------------------------------
-- checkpoint | requested_checkpoint_pct | 65.00        | percent | pg_stat_checkpointer | Requested checkpoints...
-- wal        | wal_bytes                | 104857600    | bytes   | pg_stat_wal          | WAL bytes since stats reset...
-- SAMPLE_OUTPUT_END
