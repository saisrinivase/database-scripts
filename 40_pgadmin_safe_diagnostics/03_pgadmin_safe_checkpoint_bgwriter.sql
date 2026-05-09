/*
PostgreSQL DBA Script: PgAdmin Safe Checkpoint Bgwriter
Purpose: Show checkpoint and background writer pressure across PostgreSQL 15-18 without psql conditionals.
Area: PgAdmin Safe Diagnostics
Usage: Run directly in pgAdmin Query Tool.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Creates a temporary pg_temp helper function to handle pg_stat_checkpointer availability safely.
*/
CREATE OR REPLACE FUNCTION pg_temp.pgadmin_checkpoint_bgwriter()
RETURNS TABLE (
    metric_name text,
    metric_value numeric,
    unit text,
    source_view text,
    sme_diagnosis text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_checkpointer') IS NOT NULL THEN
        RETURN QUERY EXECUTE $q$
            SELECT 'checkpoints.timed', num_timed::numeric, 'count', 'pg_stat_checkpointer', 'Timed checkpoints.' FROM pg_stat_checkpointer
            UNION ALL SELECT 'checkpoints.requested', num_requested::numeric, 'count', 'pg_stat_checkpointer', 'Requested checkpoints; high ratio indicates checkpoint pressure.' FROM pg_stat_checkpointer
            UNION ALL SELECT 'checkpoints.requested_pct', round(100.0 * num_requested / NULLIF(num_timed + num_requested, 0), 2), 'percent', 'pg_stat_checkpointer', 'Requested checkpoint percentage.' FROM pg_stat_checkpointer
            UNION ALL SELECT 'checkpoints.write_time_ms', write_time::numeric, 'milliseconds', 'pg_stat_checkpointer', 'Cumulative checkpoint write time.' FROM pg_stat_checkpointer
            UNION ALL SELECT 'checkpoints.sync_time_ms', sync_time::numeric, 'milliseconds', 'pg_stat_checkpointer', 'Cumulative checkpoint sync time.' FROM pg_stat_checkpointer
            UNION ALL SELECT 'checkpoints.buffers_written', buffers_written::numeric, 'buffers', 'pg_stat_checkpointer', 'Buffers written by checkpoints.' FROM pg_stat_checkpointer
            UNION ALL SELECT 'bgwriter.buffers_clean', buffers_clean::numeric, 'buffers', 'pg_stat_bgwriter', 'Buffers written by background writer.' FROM pg_stat_bgwriter
            UNION ALL SELECT 'bgwriter.maxwritten_clean', maxwritten_clean::numeric, 'count', 'pg_stat_bgwriter', 'Bgwriter stopped because maxpages reached.' FROM pg_stat_bgwriter
            UNION ALL SELECT 'bgwriter.buffers_alloc', buffers_alloc::numeric, 'buffers', 'pg_stat_bgwriter', 'Buffers allocated since reset.' FROM pg_stat_bgwriter
        $q$;
    ELSE
        RETURN QUERY EXECUTE $q$
            SELECT 'checkpoints.timed', checkpoints_timed::numeric, 'count', 'pg_stat_bgwriter', 'Timed checkpoints.' FROM pg_stat_bgwriter
            UNION ALL SELECT 'checkpoints.requested', checkpoints_req::numeric, 'count', 'pg_stat_bgwriter', 'Requested checkpoints; high ratio indicates checkpoint pressure.' FROM pg_stat_bgwriter
            UNION ALL SELECT 'checkpoints.requested_pct', round(100.0 * checkpoints_req / NULLIF(checkpoints_timed + checkpoints_req, 0), 2), 'percent', 'pg_stat_bgwriter', 'Requested checkpoint percentage.' FROM pg_stat_bgwriter
            UNION ALL SELECT 'checkpoints.write_time_ms', checkpoint_write_time::numeric, 'milliseconds', 'pg_stat_bgwriter', 'Cumulative checkpoint write time.' FROM pg_stat_bgwriter
            UNION ALL SELECT 'checkpoints.sync_time_ms', checkpoint_sync_time::numeric, 'milliseconds', 'pg_stat_bgwriter', 'Cumulative checkpoint sync time.' FROM pg_stat_bgwriter
            UNION ALL SELECT 'checkpoints.buffers_written', buffers_checkpoint::numeric, 'buffers', 'pg_stat_bgwriter', 'Buffers written by checkpoints.' FROM pg_stat_bgwriter
            UNION ALL SELECT 'bgwriter.buffers_clean', buffers_clean::numeric, 'buffers', 'pg_stat_bgwriter', 'Buffers written by background writer.' FROM pg_stat_bgwriter
            UNION ALL SELECT 'bgwriter.maxwritten_clean', maxwritten_clean::numeric, 'count', 'pg_stat_bgwriter', 'Bgwriter stopped because maxpages reached.' FROM pg_stat_bgwriter
            UNION ALL SELECT 'backend.buffers_backend', buffers_backend::numeric, 'buffers', 'pg_stat_bgwriter', 'Backend write pressure.' FROM pg_stat_bgwriter
        $q$;
    END IF;
END;
$$;

SELECT *
FROM pg_temp.pgadmin_checkpoint_bgwriter()
ORDER BY metric_name;

-- SAMPLE_OUTPUT_BEGIN
-- metric_name                | metric_value | unit         | source_view          | sme_diagnosis
-- ---------------------------+--------------+--------------+----------------------+-------------------------------
-- checkpoints.requested_pct  |         4.77 | percent      | pg_stat_checkpointer | Requested checkpoint percentage.
-- SAMPLE_OUTPUT_END
