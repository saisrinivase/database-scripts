/*
Purpose: Detect checkpoint pressure and backend write burden.
Area: I/O, WAL, and Checkpoints
Usage: Helps tune checkpoint_timeout, max_wal_size, and bgwriter settings.
*/
SELECT (current_setting('server_version_num')::int >= 170000) AS has_pg_stat_checkpointer \gset

\if :has_pg_stat_checkpointer
SELECT
    cp.num_timed AS checkpoints_timed,
    cp.num_requested AS checkpoints_req,
    round(100.0 * cp.num_requested / NULLIF(cp.num_timed + cp.num_requested, 0), 2) AS requested_checkpoint_pct,
    cp.write_time AS checkpoint_write_time,
    cp.sync_time AS checkpoint_sync_time,
    cp.buffers_written AS buffers_checkpoint,
    cp.slru_written,
    bg.buffers_clean,
    bg.maxwritten_clean,
    bg.buffers_alloc,
    cp.stats_reset AS checkpointer_stats_reset,
    bg.stats_reset AS bgwriter_stats_reset
FROM pg_stat_checkpointer cp
CROSS JOIN pg_stat_bgwriter bg;
\else
SELECT
    checkpoints_timed,
    checkpoints_req,
    round(100.0 * checkpoints_req / NULLIF(checkpoints_timed + checkpoints_req, 0), 2) AS requested_checkpoint_pct,
    checkpoint_write_time,
    checkpoint_sync_time,
    buffers_checkpoint,
    NULL::bigint AS slru_written,
    buffers_clean,
    maxwritten_clean,
    buffers_alloc,
    stats_reset AS checkpointer_stats_reset,
    stats_reset AS bgwriter_stats_reset
FROM pg_stat_bgwriter;
\endif
