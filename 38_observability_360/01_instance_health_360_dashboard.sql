/*
PostgreSQL DBA Script: Instance Health 360 Dashboard
Purpose: Provide one command-line health dashboard across sessions, locks, cache, temp, WAL, checkpoints, and replication.
Area: Observability 360
Usage: Run first during incidents or daily checks with psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. PostgreSQL 15-18; checkpoint columns are version-guarded for 17+.
*/
SELECT (current_setting('server_version_num')::int >= 170000) AS has_pg_stat_checkpointer \gset

\if :has_pg_stat_checkpointer
WITH
settings AS (
    SELECT current_setting('max_connections')::numeric AS max_connections
),
sessions AS (
    SELECT
        count(*)::numeric AS total_connections,
        count(*) FILTER (WHERE state = 'active')::numeric AS active_connections,
        count(*) FILTER (WHERE state = 'idle in transaction')::numeric AS idle_in_txn_connections,
        count(*) FILTER (WHERE wait_event_type IS NOT NULL)::numeric AS waiting_sessions,
        count(*) FILTER (WHERE backend_type = 'autovacuum worker')::numeric AS autovacuum_workers
    FROM pg_stat_activity
),
locks AS (
    SELECT count(*) FILTER (WHERE NOT granted)::numeric AS waiting_locks
    FROM pg_locks
),
long_tx AS (
    SELECT count(*)::numeric AS transactions_over_15m
    FROM pg_stat_activity
    WHERE xact_start IS NOT NULL
      AND now() - xact_start > interval '15 minutes'
),
db AS (
    SELECT
        sum(deadlocks)::numeric AS deadlocks,
        sum(temp_bytes)::numeric AS temp_bytes,
        sum(blks_hit)::numeric AS blks_hit,
        sum(blks_read)::numeric AS blks_read,
        sum(blk_read_time)::numeric AS blk_read_ms,
        sum(blk_write_time)::numeric AS blk_write_ms,
        sum(xact_commit)::numeric AS commits,
        sum(xact_rollback)::numeric AS rollbacks
    FROM pg_stat_database
    WHERE datname NOT IN ('template0', 'template1')
),
wal AS (
    SELECT wal_bytes::numeric, wal_buffers_full::numeric
    FROM pg_stat_wal
),
checkpoint AS (
    SELECT
        num_timed::numeric AS checkpoints_timed,
        num_requested::numeric AS checkpoints_requested,
        buffers_written::numeric AS checkpoint_buffers_written,
        write_time::numeric AS checkpoint_write_ms,
        sync_time::numeric AS checkpoint_sync_ms
    FROM pg_stat_checkpointer
),
replication AS (
    SELECT
        count(*)::numeric AS standbys,
        max(extract(epoch FROM replay_lag))::numeric AS max_replay_lag_seconds
    FROM pg_stat_replication
)
SELECT *
FROM (
    SELECT 'connections.total' AS metric_name, sessions.total_connections AS metric_value, 'count' AS unit,
           CASE WHEN sessions.total_connections >= settings.max_connections * 0.90 THEN 'CRITICAL'
                WHEN sessions.total_connections >= settings.max_connections * 0.75 THEN 'WARN'
                ELSE 'OK' END AS status,
           'pg_stat_activity' AS source_view,
           'Current backends versus max_connections.' AS purpose
    FROM sessions CROSS JOIN settings
    UNION ALL
    SELECT 'connections.active', active_connections, 'count', 'INFO', 'pg_stat_activity', 'Currently active sessions.' FROM sessions
    UNION ALL
    SELECT 'connections.idle_in_transaction', idle_in_txn_connections, 'count',
           CASE WHEN idle_in_txn_connections > 0 THEN 'WARN' ELSE 'OK' END,
           'pg_stat_activity', 'Idle transactions can hold locks and block vacuum.' FROM sessions
    UNION ALL
    SELECT 'sessions.waiting', waiting_sessions, 'count',
           CASE WHEN waiting_sessions > 0 THEN 'WARN' ELSE 'OK' END,
           'pg_stat_activity', 'Sessions currently waiting on a lock, IO, LWLock, client, or other wait event.' FROM sessions
    UNION ALL
    SELECT 'locks.waiting', waiting_locks, 'count',
           CASE WHEN waiting_locks > 0 THEN 'CRITICAL' ELSE 'OK' END,
           'pg_locks', 'Blocked lock requests.' FROM locks
    UNION ALL
    SELECT 'transactions.over_15m', transactions_over_15m, 'count',
           CASE WHEN transactions_over_15m > 0 THEN 'WARN' ELSE 'OK' END,
           'pg_stat_activity', 'Long transactions can hold snapshots and increase bloat.' FROM long_tx
    UNION ALL
    SELECT 'cache.hit_pct',
           round(100 * blks_hit / NULLIF(blks_hit + blks_read, 0), 2),
           'percent',
           CASE WHEN (100 * blks_hit / NULLIF(blks_hit + blks_read, 0)) < 95 THEN 'REVIEW' ELSE 'OK' END,
           'pg_stat_database', 'Database buffer cache hit ratio across non-template DBs.' FROM db
    UNION ALL
    SELECT 'temp.bytes', temp_bytes, 'bytes',
           CASE WHEN temp_bytes > 0 THEN 'INFO' ELSE 'OK' END,
           'pg_stat_database', 'Cumulative temp file bytes since stats reset.' FROM db
    UNION ALL
    SELECT 'deadlocks.total', deadlocks, 'count',
           CASE WHEN deadlocks > 0 THEN 'WARN' ELSE 'OK' END,
           'pg_stat_database', 'Cumulative deadlocks since stats reset.' FROM db
    UNION ALL
    SELECT 'wal.bytes', wal_bytes, 'bytes', 'INFO', 'pg_stat_wal', 'Cumulative WAL bytes since stats reset.' FROM wal
    UNION ALL
    SELECT 'wal.buffers_full', wal_buffers_full, 'count',
           CASE WHEN wal_buffers_full > 0 THEN 'REVIEW' ELSE 'OK' END,
           'pg_stat_wal', 'WAL buffers filled before writes could keep up.' FROM wal
    UNION ALL
    SELECT 'checkpoints.requested_pct',
           round(100 * checkpoints_requested / NULLIF(checkpoints_timed + checkpoints_requested, 0), 2),
           'percent',
           CASE WHEN (100 * checkpoints_requested / NULLIF(checkpoints_timed + checkpoints_requested, 0)) > 20 THEN 'WARN' ELSE 'OK' END,
           'pg_stat_checkpointer', 'High requested checkpoint ratio can indicate checkpoint/WAL pressure.' FROM checkpoint
    UNION ALL
    SELECT 'replication.standbys', standbys, 'count', 'INFO', 'pg_stat_replication', 'Connected streaming standbys.' FROM replication
    UNION ALL
    SELECT 'replication.max_replay_lag_seconds', coalesce(max_replay_lag_seconds, 0), 'seconds',
           CASE WHEN coalesce(max_replay_lag_seconds, 0) > 60 THEN 'WARN' ELSE 'OK' END,
           'pg_stat_replication', 'Largest streaming replay lag reported by primary.' FROM replication
) s
ORDER BY
    CASE status WHEN 'CRITICAL' THEN 1 WHEN 'WARN' THEN 2 WHEN 'REVIEW' THEN 3 WHEN 'INFO' THEN 4 ELSE 5 END,
    metric_name;
\else
WITH
settings AS (
    SELECT current_setting('max_connections')::numeric AS max_connections
),
sessions AS (
    SELECT
        count(*)::numeric AS total_connections,
        count(*) FILTER (WHERE state = 'active')::numeric AS active_connections,
        count(*) FILTER (WHERE state = 'idle in transaction')::numeric AS idle_in_txn_connections,
        count(*) FILTER (WHERE wait_event_type IS NOT NULL)::numeric AS waiting_sessions,
        count(*) FILTER (WHERE backend_type = 'autovacuum worker')::numeric AS autovacuum_workers
    FROM pg_stat_activity
),
locks AS (
    SELECT count(*) FILTER (WHERE NOT granted)::numeric AS waiting_locks
    FROM pg_locks
),
long_tx AS (
    SELECT count(*)::numeric AS transactions_over_15m
    FROM pg_stat_activity
    WHERE xact_start IS NOT NULL
      AND now() - xact_start > interval '15 minutes'
),
db AS (
    SELECT
        sum(deadlocks)::numeric AS deadlocks,
        sum(temp_bytes)::numeric AS temp_bytes,
        sum(blks_hit)::numeric AS blks_hit,
        sum(blks_read)::numeric AS blks_read,
        sum(blk_read_time)::numeric AS blk_read_ms,
        sum(blk_write_time)::numeric AS blk_write_ms,
        sum(xact_commit)::numeric AS commits,
        sum(xact_rollback)::numeric AS rollbacks
    FROM pg_stat_database
    WHERE datname NOT IN ('template0', 'template1')
),
wal AS (
    SELECT wal_bytes::numeric, wal_buffers_full::numeric
    FROM pg_stat_wal
),
checkpoint AS (
    SELECT
        checkpoints_timed::numeric,
        checkpoints_req::numeric AS checkpoints_requested,
        buffers_checkpoint::numeric AS checkpoint_buffers_written,
        checkpoint_write_time::numeric AS checkpoint_write_ms,
        checkpoint_sync_time::numeric AS checkpoint_sync_ms
    FROM pg_stat_bgwriter
),
replication AS (
    SELECT
        count(*)::numeric AS standbys,
        max(extract(epoch FROM replay_lag))::numeric AS max_replay_lag_seconds
    FROM pg_stat_replication
)
SELECT *
FROM (
    SELECT 'connections.total' AS metric_name, sessions.total_connections AS metric_value, 'count' AS unit,
           CASE WHEN sessions.total_connections >= settings.max_connections * 0.90 THEN 'CRITICAL'
                WHEN sessions.total_connections >= settings.max_connections * 0.75 THEN 'WARN'
                ELSE 'OK' END AS status,
           'pg_stat_activity' AS source_view,
           'Current backends versus max_connections.' AS purpose
    FROM sessions CROSS JOIN settings
    UNION ALL
    SELECT 'connections.active', active_connections, 'count', 'INFO', 'pg_stat_activity', 'Currently active sessions.' FROM sessions
    UNION ALL
    SELECT 'connections.idle_in_transaction', idle_in_txn_connections, 'count',
           CASE WHEN idle_in_txn_connections > 0 THEN 'WARN' ELSE 'OK' END,
           'pg_stat_activity', 'Idle transactions can hold locks and block vacuum.' FROM sessions
    UNION ALL
    SELECT 'sessions.waiting', waiting_sessions, 'count',
           CASE WHEN waiting_sessions > 0 THEN 'WARN' ELSE 'OK' END,
           'pg_stat_activity', 'Sessions currently waiting on a lock, IO, LWLock, client, or other wait event.' FROM sessions
    UNION ALL
    SELECT 'locks.waiting', waiting_locks, 'count',
           CASE WHEN waiting_locks > 0 THEN 'CRITICAL' ELSE 'OK' END,
           'pg_locks', 'Blocked lock requests.' FROM locks
    UNION ALL
    SELECT 'transactions.over_15m', transactions_over_15m, 'count',
           CASE WHEN transactions_over_15m > 0 THEN 'WARN' ELSE 'OK' END,
           'pg_stat_activity', 'Long transactions can hold snapshots and increase bloat.' FROM long_tx
    UNION ALL
    SELECT 'cache.hit_pct',
           round(100 * blks_hit / NULLIF(blks_hit + blks_read, 0), 2),
           'percent',
           CASE WHEN (100 * blks_hit / NULLIF(blks_hit + blks_read, 0)) < 95 THEN 'REVIEW' ELSE 'OK' END,
           'pg_stat_database', 'Database buffer cache hit ratio across non-template DBs.' FROM db
    UNION ALL
    SELECT 'temp.bytes', temp_bytes, 'bytes',
           CASE WHEN temp_bytes > 0 THEN 'INFO' ELSE 'OK' END,
           'pg_stat_database', 'Cumulative temp file bytes since stats reset.' FROM db
    UNION ALL
    SELECT 'deadlocks.total', deadlocks, 'count',
           CASE WHEN deadlocks > 0 THEN 'WARN' ELSE 'OK' END,
           'pg_stat_database', 'Cumulative deadlocks since stats reset.' FROM db
    UNION ALL
    SELECT 'wal.bytes', wal_bytes, 'bytes', 'INFO', 'pg_stat_wal', 'Cumulative WAL bytes since stats reset.' FROM wal
    UNION ALL
    SELECT 'wal.buffers_full', wal_buffers_full, 'count',
           CASE WHEN wal_buffers_full > 0 THEN 'REVIEW' ELSE 'OK' END,
           'pg_stat_wal', 'WAL buffers filled before writes could keep up.' FROM wal
    UNION ALL
    SELECT 'checkpoints.requested_pct',
           round(100 * checkpoints_requested / NULLIF(checkpoints_timed + checkpoints_requested, 0), 2),
           'percent',
           CASE WHEN (100 * checkpoints_requested / NULLIF(checkpoints_timed + checkpoints_requested, 0)) > 20 THEN 'WARN' ELSE 'OK' END,
           'pg_stat_bgwriter', 'High requested checkpoint ratio can indicate checkpoint/WAL pressure.' FROM checkpoint
    UNION ALL
    SELECT 'replication.standbys', standbys, 'count', 'INFO', 'pg_stat_replication', 'Connected streaming standbys.' FROM replication
    UNION ALL
    SELECT 'replication.max_replay_lag_seconds', coalesce(max_replay_lag_seconds, 0), 'seconds',
           CASE WHEN coalesce(max_replay_lag_seconds, 0) > 60 THEN 'WARN' ELSE 'OK' END,
           'pg_stat_replication', 'Largest streaming replay lag reported by primary.' FROM replication
) s
ORDER BY
    CASE status WHEN 'CRITICAL' THEN 1 WHEN 'WARN' THEN 2 WHEN 'REVIEW' THEN 3 WHEN 'INFO' THEN 4 ELSE 5 END,
    metric_name;
\endif

-- SAMPLE_OUTPUT_BEGIN
-- metric_name                         | metric_value | unit    | status | source_view          | purpose
-- ------------------------------------+--------------+---------+--------+----------------------+----------------------------------------------
-- connections.total                   |           42 | count   | OK     | pg_stat_activity     | Current backends versus max_connections.
-- locks.waiting                       |            0 | count   | OK     | pg_locks             | Blocked lock requests.
-- cache.hit_pct                       |        99.23 | percent | OK     | pg_stat_database     | Database buffer cache hit ratio across non-template DBs.
-- wal.bytes                           | 123456789012 | bytes   | INFO   | pg_stat_wal          | Cumulative WAL bytes since stats reset.
-- checkpoints.requested_pct           |         3.10 | percent | OK     | pg_stat_checkpointer | High requested checkpoint ratio can indicate checkpoint/WAL pressure.
-- SAMPLE_OUTPUT_END
