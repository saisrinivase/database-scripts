/*
PostgreSQL DBA Script: Bottleneck Overview Dashboard
Purpose: Provide a single-row bottleneck overview across concurrency, I/O, temp usage, locks, and checkpoints.
Area: High Speed Tuning
Usage: Run first during performance triage to identify top pressure domains. Safe for pgAdmin and psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic. Uses dynamic SQL for version-specific checkpoint columns.
*/
CREATE TEMP TABLE IF NOT EXISTS bottleneck_overview_result (
    total_connections bigint,
    active_connections bigint,
    idle_in_txn_connections bigint,
    waiting_sessions bigint,
    waiting_locks bigint,
    granted_locks bigint,
    deadlocks numeric,
    blks_read numeric,
    blks_hit numeric,
    cache_hit_pct numeric,
    temp_files numeric,
    temp_bytes numeric,
    temp_bytes_pretty text,
    blk_read_time numeric,
    blk_write_time numeric,
    checkpoints_timed numeric,
    checkpoints_req numeric,
    requested_checkpoint_pct numeric,
    buffers_checkpoint numeric,
    slru_written numeric,
    buffers_clean numeric,
    maxwritten_clean numeric,
    buffers_backend numeric,
    buffers_backend_fsync numeric,
    buffers_alloc numeric,
    checkpoint_write_time numeric,
    checkpoint_sync_time numeric,
    checkpointer_stats_reset timestamptz,
    bgwriter_stats_reset timestamptz,
    top_bottleneck_hint text
);

TRUNCATE bottleneck_overview_result;

DO $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_checkpointer') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO bottleneck_overview_result
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
                    NULL::numeric AS buffers_backend,
                    NULL::numeric AS buffers_backend_fsync,
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
            CROSS JOIN bg
        $sql$;
    ELSE
        EXECUTE $sql$
            INSERT INTO bottleneck_overview_result
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
                    NULL::numeric AS checkpoints_timed,
                    NULL::numeric AS checkpoints_req,
                    NULL::numeric AS checkpoint_write_time,
                    NULL::numeric AS checkpoint_sync_time,
                    NULL::numeric AS buffers_checkpoint,
                    NULL::numeric AS slru_written,
                    buffers_clean,
                    maxwritten_clean,
                    NULL::numeric AS buffers_backend,
                    NULL::numeric AS buffers_backend_fsync,
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
                NULL::numeric AS requested_checkpoint_pct,
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
                    WHEN conn.idle_in_txn_connections > 0 THEN 'Idle transaction risk'
                    ELSE 'No dominant global bottleneck found'
                END AS top_bottleneck_hint
            FROM conn
            CROSS JOIN waits
            CROSS JOIN db
            CROSS JOIN locks
            CROSS JOIN bg
        $sql$;
    END IF;
END $$;

SELECT *
FROM bottleneck_overview_result;

-- SAMPLE_OUTPUT_BEGIN
-- total_connections | active_connections | waiting_sessions | cache_hit_pct | temp_bytes_pretty | requested_checkpoint_pct | top_bottleneck_hint
-- ------------------+--------------------+------------------+---------------+-------------------+--------------------------+------------------------
--                 9 |                  1 |                8 |         92.97 | 3980 MB           |                     6.48 | No dominant global...
-- SAMPLE_OUTPUT_END
