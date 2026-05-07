/*
PostgreSQL DBA Script: Bgwriter Checkpoint Stats
Purpose: Review checkpointer and background writer behavior.
Area: Maintenance and Monitoring
Usage: Reset stats only during controlled measurement windows.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT (current_setting('server_version_num')::int >= 170000) AS has_pg_stat_checkpointer \gset

\if :has_pg_stat_checkpointer
SELECT
    cp.num_timed AS checkpoints_timed,
    cp.num_requested AS checkpoints_req,
    cp.write_time AS checkpoint_write_time,
    cp.sync_time AS checkpoint_sync_time,
    cp.buffers_written AS buffers_checkpoint,
    cp.slru_written,
    bg.buffers_clean,
    bg.maxwritten_clean,
    NULL::bigint AS buffers_backend,
    NULL::bigint AS buffers_backend_fsync,
    bg.buffers_alloc,
    cp.stats_reset AS checkpointer_stats_reset,
    bg.stats_reset AS bgwriter_stats_reset
FROM pg_stat_checkpointer cp
CROSS JOIN pg_stat_bgwriter bg;
\else
SELECT
    checkpoints_timed,
    checkpoints_req,
    checkpoint_write_time,
    checkpoint_sync_time,
    buffers_checkpoint,
    NULL::bigint AS slru_written,
    buffers_clean,
    maxwritten_clean,
    buffers_backend,
    buffers_backend_fsync,
    buffers_alloc,
    stats_reset AS checkpointer_stats_reset,
    stats_reset AS bgwriter_stats_reset
FROM pg_stat_bgwriter;
\endif




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  checkpoints_timed | checkpoints_req | checkpoint_write_time | checkpoint_sync_time | buffers_checkpoint | slru_written | buffers_clean | maxwritten_clean | buffers_backend | buffers_backend_fsync | buffers_alloc |   checkpointer_stats_reset    |     bgwriter_stats_reset      
-- -------------------+-----------------+-----------------------+----------------------+--------------------+--------------+---------------+------------------+-----------------+-----------------------+---------------+-------------------------------+-------------------------------
--                851 |              59 |               4142695 |                48708 |              68025 |          216 |        277435 |             2551 |                 |                       |      10942095 | 2026-01-31 20:40:48.109778-05 | 2026-01-31 20:40:48.109778-05
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END

