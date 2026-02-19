/*
Purpose: Provide a single-row bottleneck overview across concurrency, I/O, temp usage, locks, and checkpoints.
Area: High Speed Tuning
Usage: Run first during performance triage to identify top pressure domains.
*/
SELECT (current_setting('server_version_num')::int >= 170000) AS has_pg_stat_checkpointer \gset

\if :has_pg_stat_checkpointer
WITH conn AS (
    SELECT
        count(*) AS total_connections,
        count(*) FILTER (WHERE state = 'active') AS active_connections,
        count(*) FILTER (WHERE state = 'idle in transaction') AS idle_in_txn_connections
    FROM pg_stat_activity
),
waits AS (
    SELECT count(*) FILTER (WHERE wait_event_type IS NOT NULL) AS waiting_sessions
    FROM pg_stat_activity
),
db AS (
    SELECT
        sum(blks_read) AS blks_read,
        sum(blks_hit) AS blks_hit,
        sum(temp_files) AS temp_files,
        sum(temp_bytes) AS temp_bytes,
        sum(blk_read_time) AS blk_read_time,
        sum(blk_write_time) AS blk_write_time,
        sum(deadlocks) AS deadlocks
    FROM pg_stat_database
    WHERE datname NOT IN ('template0', 'template1')
),
locks AS (
    SELECT
        count(*) FILTER (WHERE NOT granted) AS waiting_locks,
        count(*) FILTER (WHERE granted) AS granted_locks
    FROM pg_locks
),
bg AS (
    SELECT
        cp.num_timed AS checkpoints_timed,
        cp.num_requested AS checkpoints_req,
        cp.write_time AS checkpoint_write_time,
        cp.sync_time AS checkpoint_sync_time,
        cp.buffers_written AS buffers_checkpoint,
        cp.slru_written,
        bgw.buffers_clean,
        bgw.maxwritten_clean,
        NULL::bigint AS buffers_backend,
        NULL::bigint AS buffers_backend_fsync,
        bgw.buffers_alloc,
        cp.stats_reset AS checkpointer_stats_reset,
        bgw.stats_reset AS bgwriter_stats_reset
    FROM pg_stat_checkpointer cp
    CROSS JOIN pg_stat_bgwriter bgw
)
SELECT
    conn.total_connections,
    conn.active_connections,
    conn.idle_in_txn_connections,
    waits.waiting_sessions,
    locks.waiting_locks,
    locks.granted_locks,
    db.deadlocks,
    db.blks_read,
    db.blks_hit,
    round(100.0 * db.blks_hit / NULLIF(db.blks_hit + db.blks_read, 0), 2) AS cache_hit_pct,
    db.temp_files,
    db.temp_bytes,
    pg_size_pretty(coalesce(db.temp_bytes, 0)::bigint) AS temp_bytes_pretty,
    db.blk_read_time,
    db.blk_write_time,
    bg.checkpoints_timed,
    bg.checkpoints_req,
    round(100.0 * bg.checkpoints_req / NULLIF(bg.checkpoints_timed + bg.checkpoints_req, 0), 2) AS requested_checkpoint_pct,
    bg.buffers_checkpoint,
    bg.slru_written,
    bg.buffers_clean,
    bg.maxwritten_clean,
    bg.buffers_backend,
    bg.buffers_backend_fsync,
    bg.buffers_alloc,
    bg.checkpoint_write_time,
    bg.checkpoint_sync_time,
    bg.checkpointer_stats_reset,
    bg.bgwriter_stats_reset,
    CASE
        WHEN db.deadlocks > 0 THEN 'Locking risk'
        WHEN locks.waiting_locks > 0 THEN 'Blocking risk'
        WHEN db.temp_bytes > 1024::bigint * 1024 * 1024 * 10 THEN 'Spill/temp I/O risk'
        WHEN bg.checkpoints_req > bg.checkpoints_timed THEN 'Checkpoint pressure'
        WHEN conn.idle_in_txn_connections > 0 THEN 'Idle transaction risk'
        ELSE 'No dominant global bottleneck found'
    END AS top_bottleneck_hint
FROM conn
CROSS JOIN waits
CROSS JOIN db
CROSS JOIN locks
CROSS JOIN bg;
\else
WITH conn AS (
    SELECT
        count(*) AS total_connections,
        count(*) FILTER (WHERE state = 'active') AS active_connections,
        count(*) FILTER (WHERE state = 'idle in transaction') AS idle_in_txn_connections
    FROM pg_stat_activity
),
waits AS (
    SELECT count(*) FILTER (WHERE wait_event_type IS NOT NULL) AS waiting_sessions
    FROM pg_stat_activity
),
db AS (
    SELECT
        sum(blks_read) AS blks_read,
        sum(blks_hit) AS blks_hit,
        sum(temp_files) AS temp_files,
        sum(temp_bytes) AS temp_bytes,
        sum(blk_read_time) AS blk_read_time,
        sum(blk_write_time) AS blk_write_time,
        sum(deadlocks) AS deadlocks
    FROM pg_stat_database
    WHERE datname NOT IN ('template0', 'template1')
),
locks AS (
    SELECT
        count(*) FILTER (WHERE NOT granted) AS waiting_locks,
        count(*) FILTER (WHERE granted) AS granted_locks
    FROM pg_locks
),
bg AS (
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
    FROM pg_stat_bgwriter
)
SELECT
    conn.total_connections,
    conn.active_connections,
    conn.idle_in_txn_connections,
    waits.waiting_sessions,
    locks.waiting_locks,
    locks.granted_locks,
    db.deadlocks,
    db.blks_read,
    db.blks_hit,
    round(100.0 * db.blks_hit / NULLIF(db.blks_hit + db.blks_read, 0), 2) AS cache_hit_pct,
    db.temp_files,
    db.temp_bytes,
    pg_size_pretty(coalesce(db.temp_bytes, 0)::bigint) AS temp_bytes_pretty,
    db.blk_read_time,
    db.blk_write_time,
    bg.checkpoints_timed,
    bg.checkpoints_req,
    round(100.0 * bg.checkpoints_req / NULLIF(bg.checkpoints_timed + bg.checkpoints_req, 0), 2) AS requested_checkpoint_pct,
    bg.buffers_checkpoint,
    bg.slru_written,
    bg.buffers_clean,
    bg.maxwritten_clean,
    bg.buffers_backend,
    bg.buffers_backend_fsync,
    bg.buffers_alloc,
    bg.checkpoint_write_time,
    bg.checkpoint_sync_time,
    bg.checkpointer_stats_reset,
    bg.bgwriter_stats_reset,
    CASE
        WHEN db.deadlocks > 0 THEN 'Locking risk'
        WHEN locks.waiting_locks > 0 THEN 'Blocking risk'
        WHEN db.temp_bytes > 1024::bigint * 1024 * 1024 * 10 THEN 'Spill/temp I/O risk'
        WHEN bg.checkpoints_req > bg.checkpoints_timed THEN 'Checkpoint pressure'
        WHEN conn.idle_in_txn_connections > 0 THEN 'Idle transaction risk'
        ELSE 'No dominant global bottleneck found'
    END AS top_bottleneck_hint
FROM conn
CROSS JOIN waits
CROSS JOIN db
CROSS JOIN locks
CROSS JOIN bg;
\endif




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  total_connections | active_connections | idle_in_txn_connections | waiting_sessions | waiting_locks | granted_locks | deadlocks | blks_read | blks_hit  | cache_hit_pct | temp_files | temp_bytes | temp_bytes_pretty | blk_read_time | blk_write_time | checkpoints_timed | checkpoints_req | requested_checkpoint_pct | buffers_checkpoint | slru_written | buffers_clean | maxwritten_clean | buffers_backend | buffers_backend_fsync | buffers_alloc | checkpoint_write_time | checkpoint_sync_time |   checkpointer_stats_reset    |     bgwriter_stats_reset      |         top_bottleneck_hint         
-- -------------------+--------------------+-------------------------+------------------+---------------+---------------+-----------+-----------+-----------+---------------+------------+------------+-------------------+---------------+----------------+-------------------+-----------------+--------------------------+--------------------+--------------+---------------+------------------+-----------------+-----------------------+---------------+-----------------------+----------------------+-------------------------------+-------------------------------+-------------------------------------
--                  9 |                  1 |                       0 |                8 |             0 |            12 |         0 |  14246309 | 188338172 |         92.97 |         58 | 4172992384 | 3980 MB           |             0 |              0 |               851 |              59 |                     6.48 |              68025 |          216 |        277435 |             2551 |                 |                       |      10942179 |               4142695 |                48708 | 2026-01-31 20:40:48.109778-05 | 2026-01-31 20:40:48.109778-05 | No dominant global bottleneck found
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
