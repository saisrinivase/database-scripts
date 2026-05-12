/*
PostgreSQL DBA Script: Bgwriter Checkpointer Pressure
Purpose: Quantify checkpointer/bgwriter pressure and backend-write fallback behavior.
Area: Background Processes and Memory Pressure
Usage: Run periodically; compare requested checkpoint ratio and bgwriter pressure. Safe for pgAdmin and psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic. Version-specific checkpointer columns are handled with dynamic SQL.
*/
CREATE TEMP TABLE IF NOT EXISTS bgwriter_checkpointer_pressure_result (
    checkpoints_timed numeric,
    checkpoints_req numeric,
    requested_checkpoint_pct numeric,
    checkpoint_write_time_ms numeric,
    checkpoint_sync_time_ms numeric,
    buffers_checkpoint numeric,
    buffers_clean numeric,
    maxwritten_clean numeric,
    buffers_backend numeric,
    buffers_backend_fsync numeric,
    buffers_alloc numeric,
    pressure_label text,
    checkpointer_stats_reset timestamptz,
    bgwriter_stats_reset timestamptz
);

TRUNCATE bgwriter_checkpointer_pressure_result;

DO $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_checkpointer') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO bgwriter_checkpointer_pressure_result
            SELECT
                cp.num_timed,
                cp.num_requested,
                round(
                    CASE WHEN cp.num_timed + cp.num_requested = 0 THEN 0
                         ELSE 100.0 * cp.num_requested::numeric / (cp.num_timed + cp.num_requested)
                    END,
                    2
                ),
                cp.write_time,
                cp.sync_time,
                cp.buffers_written,
                bg.buffers_clean,
                bg.maxwritten_clean,
                NULL::numeric,
                NULL::numeric,
                bg.buffers_alloc,
                CASE
                    WHEN cp.num_requested > cp.num_timed THEN 'CHECKPOINT_PRESSURE_HIGH'
                    WHEN bg.maxwritten_clean > 0 THEN 'BGWRITER_MAXWRITTEN_EVENTS'
                    ELSE 'STABLE'
                END,
                cp.stats_reset,
                bg.stats_reset
            FROM pg_stat_checkpointer cp
            CROSS JOIN pg_stat_bgwriter bg
        $sql$;
    ELSE
        INSERT INTO bgwriter_checkpointer_pressure_result
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
            CASE
                WHEN maxwritten_clean > 0 THEN 'BGWRITER_MAXWRITTEN_EVENTS'
                ELSE 'STABLE'
            END,
            stats_reset,
            stats_reset
        FROM pg_stat_bgwriter;
    END IF;
END $$;

SELECT *
FROM bgwriter_checkpointer_pressure_result;

-- SAMPLE_OUTPUT_BEGIN
-- checkpoints_timed | checkpoints_req | requested_checkpoint_pct | checkpoint_write_time_ms | pressure_label
-- ------------------+-----------------+--------------------------+--------------------------+----------------------------
--               929 |              61 |                     6.16 |                  8271244 | BGWRITER_MAXWRITTEN_EVENTS
-- SAMPLE_OUTPUT_END
