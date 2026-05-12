/*
PostgreSQL DBA Script: Checkpoint Fsync Pressure
Purpose: Detect checkpoint and fsync pressure indicative of storage or config issues.
Area: Physical and Cloud Diagnostics
Usage: Review with WAL/checkpoint settings and cloud disk metrics. Safe for pgAdmin and psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic. Version-specific checkpointer columns are handled with dynamic SQL.
*/
CREATE TEMP TABLE IF NOT EXISTS checkpoint_fsync_pressure_result (
    checkpoints_timed numeric,
    checkpoints_req numeric,
    checkpoint_write_time numeric,
    checkpoint_sync_time numeric,
    buffers_checkpoint numeric,
    slru_written numeric,
    buffers_clean numeric,
    maxwritten_clean numeric,
    buffers_alloc numeric,
    recommendation text,
    checkpointer_stats_reset timestamptz,
    bgwriter_stats_reset timestamptz
);

TRUNCATE checkpoint_fsync_pressure_result;

DO $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_checkpointer') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO checkpoint_fsync_pressure_result
            SELECT
                cp.num_timed,
                cp.num_requested,
                cp.write_time,
                cp.sync_time,
                cp.buffers_written,
                cp.slru_written,
                bg.buffers_clean,
                bg.maxwritten_clean,
                bg.buffers_alloc,
                CASE
                    WHEN cp.num_requested > cp.num_timed THEN 'Checkpoint pressure'
                    WHEN cp.sync_time > cp.write_time THEN 'Checkpoint fsync/sync pressure'
                    ELSE 'Normal checkpoint profile'
                END,
                cp.stats_reset,
                bg.stats_reset
            FROM pg_stat_checkpointer cp
            CROSS JOIN pg_stat_bgwriter bg
        $sql$;
    ELSE
        INSERT INTO checkpoint_fsync_pressure_result
        SELECT
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            buffers_clean,
            maxwritten_clean,
            buffers_alloc,
            'Checkpoint counters are not available in this PostgreSQL version/view.',
            stats_reset,
            stats_reset
        FROM pg_stat_bgwriter;
    END IF;
END $$;

SELECT *
FROM checkpoint_fsync_pressure_result;

-- SAMPLE_OUTPUT_BEGIN
-- checkpoints_timed | checkpoints_req | checkpoint_write_time | checkpoint_sync_time | recommendation
-- ------------------+-----------------+-----------------------+----------------------+---------------------------
--               851 |              59 |               4142695 |                48708 | Normal checkpoint profile
-- SAMPLE_OUTPUT_END
