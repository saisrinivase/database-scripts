/*
PostgreSQL DBA Script: Checkpoint Pressure Indicators
Purpose: Detect checkpoint pressure and backend write burden.
Area: I/O, WAL, and Checkpoints
Usage: Helps tune checkpoint_timeout, max_wal_size, and bgwriter settings. Safe for pgAdmin and psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic. Version-specific checkpointer columns are handled with dynamic SQL.
*/
CREATE TEMP TABLE IF NOT EXISTS checkpoint_pressure_result (
    checkpoints_timed numeric,
    checkpoints_req numeric,
    requested_checkpoint_pct numeric,
    checkpoint_write_time numeric,
    checkpoint_sync_time numeric,
    buffers_checkpoint numeric,
    slru_written numeric,
    buffers_clean numeric,
    maxwritten_clean numeric,
    buffers_alloc numeric,
    checkpointer_stats_reset timestamptz,
    bgwriter_stats_reset timestamptz,
    recommendation text
);

TRUNCATE checkpoint_pressure_result;

DO $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_checkpointer') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO checkpoint_pressure_result
            SELECT
                cp.num_timed,
                cp.num_requested,
                round(100.0 * cp.num_requested / NULLIF(cp.num_timed + cp.num_requested, 0), 2),
                cp.write_time,
                cp.sync_time,
                cp.buffers_written,
                cp.slru_written,
                bg.buffers_clean,
                bg.maxwritten_clean,
                bg.buffers_alloc,
                cp.stats_reset,
                bg.stats_reset,
                CASE
                    WHEN cp.num_requested > cp.num_timed THEN 'Checkpoint pressure: review max_wal_size and checkpoint cadence.'
                    WHEN bg.maxwritten_clean > 0 THEN 'Bgwriter maxwritten events present: review bgwriter and dirty buffer pressure.'
                    ELSE 'Normal checkpoint profile.'
                END
            FROM pg_stat_checkpointer cp
            CROSS JOIN pg_stat_bgwriter bg
        $sql$;
    ELSE
        INSERT INTO checkpoint_pressure_result
        SELECT
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            buffers_clean,
            maxwritten_clean,
            buffers_alloc,
            stats_reset,
            stats_reset,
            CASE
                WHEN maxwritten_clean > 0 THEN 'Bgwriter maxwritten events present: review bgwriter and dirty buffer pressure.'
                ELSE 'Checkpoint request counters are not available in this PostgreSQL version/view.'
            END
        FROM pg_stat_bgwriter;
    END IF;
END $$;

SELECT *
FROM checkpoint_pressure_result;

-- SAMPLE_OUTPUT_BEGIN
-- checkpoints_timed | checkpoints_req | requested_checkpoint_pct | buffers_checkpoint | maxwritten_clean | recommendation
-- ------------------+-----------------+--------------------------+--------------------+------------------+---------------------------
--               851 |              59 |                     6.48 |              68025 |             2551 | Bgwriter maxwritten...
-- SAMPLE_OUTPUT_END
