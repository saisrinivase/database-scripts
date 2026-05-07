/*
PostgreSQL DBA Script: Bgwriter Checkpointer Pressure
Purpose: Quantify checkpointer/bgwriter pressure and backend-write fallback behavior.
Area: Background Processes and Memory Pressure
Usage: Run periodically; compare requested checkpoint ratio and backend write pressure.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT (current_setting('server_version_num')::int >= 170000) AS has_pg_stat_checkpointer \gset

\if :has_pg_stat_checkpointer
WITH s AS (
    SELECT
        cp.num_timed AS checkpoints_timed,
        cp.num_requested AS checkpoints_req,
        cp.write_time AS checkpoint_write_time_ms,
        cp.sync_time AS checkpoint_sync_time_ms,
        cp.buffers_written AS buffers_checkpoint,
        bg.buffers_clean,
        bg.maxwritten_clean,
        NULL::bigint AS buffers_backend,
        NULL::bigint AS buffers_backend_fsync,
        bg.buffers_alloc,
        cp.stats_reset AS checkpointer_stats_reset,
        bg.stats_reset AS bgwriter_stats_reset
    FROM pg_stat_checkpointer cp
    CROSS JOIN pg_stat_bgwriter bg
)
SELECT
    checkpoints_timed,
    checkpoints_req,
    round(
        CASE WHEN checkpoints_timed + checkpoints_req = 0 THEN 0
             ELSE 100.0 * checkpoints_req::numeric / (checkpoints_timed + checkpoints_req)
        END,
        2
    ) AS requested_checkpoint_pct,
    checkpoint_write_time_ms,
    checkpoint_sync_time_ms,
    buffers_checkpoint,
    buffers_clean,
    maxwritten_clean,
    buffers_backend,
    buffers_backend_fsync,
    buffers_alloc,
    CASE
        WHEN checkpoints_req > checkpoints_timed THEN 'CHECKPOINT_PRESSURE_HIGH'
        WHEN maxwritten_clean > 0 THEN 'BGWRITER_MAXWRITTEN_EVENTS'
        ELSE 'STABLE'
    END AS pressure_label,
    checkpointer_stats_reset,
    bgwriter_stats_reset
FROM s;
\else
WITH s AS (
    SELECT
        checkpoints_timed,
        checkpoints_req,
        checkpoint_write_time AS checkpoint_write_time_ms,
        checkpoint_sync_time AS checkpoint_sync_time_ms,
        buffers_checkpoint,
        buffers_clean,
        maxwritten_clean,
        buffers_backend,
        buffers_backend_fsync,
        buffers_alloc,
        stats_reset AS checkpointer_stats_reset,
        stats_reset AS bgwriter_stats_reset
    FROM pg_stat_bgwriter
)
SELECT
    checkpoints_timed,
    checkpoints_req,
    round(
        CASE WHEN checkpoints_timed + checkpoints_req = 0 THEN 0
             ELSE 100.0 * checkpoints_req::numeric / (checkpoints_timed + checkpoints_req)
        END,
        2
    ) AS requested_checkpoint_pct,
    checkpoint_write_time_ms,
    checkpoint_sync_time_ms,
    buffers_checkpoint,
    buffers_clean,
    maxwritten_clean,
    buffers_backend,
    buffers_backend_fsync,
    buffers_alloc,
    CASE
        WHEN checkpoints_req > checkpoints_timed THEN 'CHECKPOINT_PRESSURE_HIGH'
        WHEN buffers_backend_fsync > 0 THEN 'BACKEND_FSYNC_PRESSURE'
        WHEN maxwritten_clean > 0 THEN 'BGWRITER_MAXWRITTEN_EVENTS'
        ELSE 'STABLE'
    END AS pressure_label,
    checkpointer_stats_reset,
    bgwriter_stats_reset
FROM s;
\endif


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  checkpoints_timed | checkpoints_req | requested_checkpoint_pct | checkpoint_write_time_ms | checkpoint_sync_time_ms | buffers_checkpoint | buffers_clean | maxwritten_clean | buffers_backend | buffers_backend_fsync | buffers_alloc |       pressure_label       |   checkpointer_stats_reset    |     bgwriter_stats_reset      
-- -------------------+-----------------+--------------------------+--------------------------+-------------------------+--------------------+---------------+------------------+-----------------+-----------------------+---------------+----------------------------+-------------------------------+-------------------------------
--                929 |              61 |                     6.16 |                  8271244 |                   49221 |             128988 |        434549 |             3773 |                 |                       |      17163921 | BGWRITER_MAXWRITTEN_EVENTS | 2026-01-31 20:40:48.109778-05 | 2026-01-31 20:40:48.109778-05
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END

