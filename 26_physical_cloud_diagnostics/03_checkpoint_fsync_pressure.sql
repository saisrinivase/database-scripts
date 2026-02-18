/*
Purpose: Detect checkpoint and fsync pressure indicative of storage or config issues.
Area: Physical and Cloud Diagnostics
Usage: Review with WAL/checkpoint settings and cloud disk metrics.
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
    bg.buffers_alloc,
    CASE
        WHEN cp.num_requested > cp.num_timed THEN 'Checkpoint pressure'
        ELSE 'Normal checkpoint profile'
    END AS recommendation,
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
    buffers_alloc,
    CASE
        WHEN checkpoints_req > checkpoints_timed THEN 'Checkpoint pressure'
        ELSE 'Normal checkpoint profile'
    END AS recommendation,
    stats_reset AS checkpointer_stats_reset,
    stats_reset AS bgwriter_stats_reset
FROM pg_stat_bgwriter;
\endif
