/*
PostgreSQL DBA Script: Bgwriter Checkpoint Stats
Purpose: Review checkpointer and background writer behavior.
Area: Maintenance and Monitoring
Usage: Reset stats only during controlled measurement windows. Safe for pgAdmin and psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic. Version-specific checkpointer columns are handled with dynamic SQL.
*/
CREATE TEMP TABLE IF NOT EXISTS bgwriter_checkpoint_stats_result (
    checkpoints_timed numeric,
    checkpoints_req numeric,
    checkpoint_write_time numeric,
    checkpoint_sync_time numeric,
    buffers_checkpoint numeric,
    slru_written numeric,
    buffers_clean numeric,
    maxwritten_clean numeric,
    buffers_backend numeric,
    buffers_backend_fsync numeric,
    buffers_alloc numeric,
    checkpointer_stats_reset timestamptz,
    bgwriter_stats_reset timestamptz
);

TRUNCATE bgwriter_checkpoint_stats_result;

DO $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_checkpointer') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO bgwriter_checkpoint_stats_result
            SELECT
                cp.num_timed,
                cp.num_requested,
                cp.write_time,
                cp.sync_time,
                cp.buffers_written,
                cp.slru_written,
                bg.buffers_clean,
                bg.maxwritten_clean,
                NULL::numeric,
                NULL::numeric,
                bg.buffers_alloc,
                cp.stats_reset,
                bg.stats_reset
            FROM pg_stat_checkpointer cp
            CROSS JOIN pg_stat_bgwriter bg
        $sql$;
    ELSE
        INSERT INTO bgwriter_checkpoint_stats_result
        SELECT
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            buffers_clean,
            maxwritten_clean,
            NULL::numeric,
            NULL::numeric,
            buffers_alloc,
            stats_reset,
            stats_reset
        FROM pg_stat_bgwriter;
    END IF;
END $$;

SELECT *
FROM bgwriter_checkpoint_stats_result;

-- SAMPLE_OUTPUT_BEGIN
-- checkpoints_timed | checkpoints_req | checkpoint_write_time | checkpoint_sync_time | buffers_checkpoint | slru_written | buffers_clean | maxwritten_clean | buffers_alloc
-- ------------------+-----------------+-----------------------+----------------------+--------------------+--------------+---------------+------------------+--------------
--               851 |              59 |               4142695 |                48708 |              68025 |          216 |        277435 |             2551 |     10942095
-- SAMPLE_OUTPUT_END
