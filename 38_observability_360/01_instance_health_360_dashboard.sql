/*
PostgreSQL DBA Script: Instance Health 360 Dashboard
Purpose: Provide one copy/paste-safe health dashboard across sessions, locks, cache, temp, WAL,
         checkpoints, and replication.
Area: Observability 360
Usage: Run first during incidents or daily checks in pgAdmin or psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. PostgreSQL 15+. Version-specific checkpoint views are handled with dynamic SQL.
*/

CREATE TEMP TABLE IF NOT EXISTS obs360_instance_health_report (
    metric_name text,
    metric_value numeric,
    unit text,
    status text,
    source_view text,
    purpose text,
    recommended_action text
);

TRUNCATE obs360_instance_health_report;

WITH
settings AS (
    SELECT current_setting('max_connections')::numeric AS max_connections
),
sessions AS (
    SELECT
        count(*)::numeric AS total_connections,
        count(*) FILTER (WHERE state = 'active')::numeric AS active_connections,
        count(*) FILTER (WHERE state = 'idle in transaction')::numeric AS idle_in_txn_connections,
        count(*) FILTER (WHERE wait_event_type IS NOT NULL)::numeric AS waiting_sessions
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
        sum(blks_read)::numeric AS blks_read
    FROM pg_stat_database
    WHERE datname NOT IN ('template0', 'template1')
),
wal AS (
    SELECT wal_bytes::numeric, wal_buffers_full::numeric
    FROM pg_stat_wal
),
replication AS (
    SELECT
        count(*)::numeric AS standbys,
        max(extract(epoch FROM replay_lag))::numeric AS max_replay_lag_seconds
    FROM pg_stat_replication
)
INSERT INTO obs360_instance_health_report
SELECT 'connections.total', sessions.total_connections, 'count',
       CASE WHEN sessions.total_connections >= settings.max_connections * 0.90 THEN 'CRITICAL'
            WHEN sessions.total_connections >= settings.max_connections * 0.75 THEN 'WARN'
            ELSE 'OK' END,
       'pg_stat_activity',
       'Current backends versus max_connections.',
       'If WARN/CRITICAL, review connection pool sizing, idle sessions, and max_connections headroom.'
FROM sessions CROSS JOIN settings
UNION ALL
SELECT 'connections.active', active_connections, 'count', 'INFO',
       'pg_stat_activity', 'Currently active sessions.', 'Use activity and top SQL scripts if active sessions are high.' FROM sessions
UNION ALL
SELECT 'connections.idle_in_transaction', idle_in_txn_connections, 'count',
       CASE WHEN idle_in_txn_connections > 0 THEN 'WARN' ELSE 'OK' END,
       'pg_stat_activity', 'Idle transactions can hold locks and block vacuum.',
       'Terminate or fix idle-in-transaction application behavior when persistent.' FROM sessions
UNION ALL
SELECT 'sessions.waiting', waiting_sessions, 'count',
       CASE WHEN waiting_sessions > 0 THEN 'WARN' ELSE 'OK' END,
       'pg_stat_activity', 'Sessions currently waiting on a wait event.',
       'Run 04_wait_event_hotspots.sql and lock-chain scripts for details.' FROM sessions
UNION ALL
SELECT 'locks.waiting', waiting_locks, 'count',
       CASE WHEN waiting_locks > 0 THEN 'CRITICAL' ELSE 'OK' END,
       'pg_locks', 'Blocked lock requests.',
       'Run blocking diagnostics immediately if nonzero.' FROM locks
UNION ALL
SELECT 'transactions.over_15m', transactions_over_15m, 'count',
       CASE WHEN transactions_over_15m > 0 THEN 'WARN' ELSE 'OK' END,
       'pg_stat_activity', 'Long transactions can hold snapshots and increase bloat.',
       'Find long transactions and confirm whether they can be cancelled.' FROM long_tx
UNION ALL
SELECT 'cache.hit_pct',
       round(100 * blks_hit / NULLIF(blks_hit + blks_read, 0), 2),
       'percent',
       CASE WHEN (100 * blks_hit / NULLIF(blks_hit + blks_read, 0)) < 95 THEN 'REVIEW' ELSE 'OK' END,
       'pg_stat_database', 'Database buffer cache hit ratio across non-template DBs.',
       'Low value can indicate cold cache, sequential scans, undersized memory, or workload shifts.' FROM db
UNION ALL
SELECT 'temp.bytes', temp_bytes, 'bytes',
       CASE WHEN temp_bytes > 0 THEN 'INFO' ELSE 'OK' END,
       'pg_stat_database', 'Cumulative temp file bytes since stats reset.',
       'If growing quickly, review sort/hash spill scripts and work_mem-sensitive queries.' FROM db
UNION ALL
SELECT 'deadlocks.total', deadlocks, 'count',
       CASE WHEN deadlocks > 0 THEN 'WARN' ELSE 'OK' END,
       'pg_stat_database', 'Cumulative deadlocks since stats reset.',
       'Review application transaction order and deadlock logs.' FROM db
UNION ALL
SELECT 'wal.bytes', wal_bytes, 'bytes', 'INFO',
       'pg_stat_wal', 'Cumulative WAL bytes since stats reset.',
       'Use snapshots to calculate WAL generation rate.' FROM wal
UNION ALL
SELECT 'wal.buffers_full', wal_buffers_full, 'count',
       CASE WHEN wal_buffers_full > 0 THEN 'REVIEW' ELSE 'OK' END,
       'pg_stat_wal', 'WAL buffers filled before writes could keep up.',
       'Review WAL/checkpoint pressure and storage write latency.' FROM wal
UNION ALL
SELECT 'replication.standbys', standbys, 'count', 'INFO',
       'pg_stat_replication', 'Connected streaming standbys.',
       'If expected standbys are missing, review replication dashboard.' FROM replication
UNION ALL
SELECT 'replication.max_replay_lag_seconds', coalesce(max_replay_lag_seconds, 0), 'seconds',
       CASE WHEN coalesce(max_replay_lag_seconds, 0) > 60 THEN 'WARN' ELSE 'OK' END,
       'pg_stat_replication', 'Largest streaming replay lag reported by primary.',
       'If lag is high, review slots, WAL retained, and standby replay health.' FROM replication;

DO $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_checkpointer') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO obs360_instance_health_report
            SELECT 'checkpoints.requested_pct',
                   round(100.0 * num_requested / NULLIF(num_timed + num_requested, 0), 2),
                   'percent',
                   CASE WHEN (100.0 * num_requested / NULLIF(num_timed + num_requested, 0)) > 20 THEN 'WARN' ELSE 'OK' END,
                   'pg_stat_checkpointer',
                   'High requested checkpoint ratio can indicate checkpoint/WAL pressure.',
                   'Review max_wal_size, checkpoint_timeout, checkpoint_completion_target, and storage latency.'
            FROM pg_stat_checkpointer
            UNION ALL
            SELECT 'checkpoints.write_time_ms', write_time::numeric, 'milliseconds', 'INFO',
                   'pg_stat_checkpointer', 'Cumulative checkpoint write time.',
                   'Use deltas to identify checkpoint write pressure.'
            FROM pg_stat_checkpointer
            UNION ALL
            SELECT 'checkpoints.sync_time_ms', sync_time::numeric, 'milliseconds', 'INFO',
                   'pg_stat_checkpointer', 'Cumulative checkpoint sync time.',
                   'High sync deltas can indicate storage latency.'
            FROM pg_stat_checkpointer
        $sql$;
    ELSE
        EXECUTE $sql$
            INSERT INTO obs360_instance_health_report
            SELECT 'checkpoints.requested_pct',
                   round(100.0 * checkpoints_req / NULLIF(checkpoints_timed + checkpoints_req, 0), 2),
                   'percent',
                   CASE WHEN (100.0 * checkpoints_req / NULLIF(checkpoints_timed + checkpoints_req, 0)) > 20 THEN 'WARN' ELSE 'OK' END,
                   'pg_stat_bgwriter',
                   'Requested checkpoint ratio from PostgreSQL 15/16 counters.',
                   'Review max_wal_size, checkpoint_timeout, checkpoint_completion_target, and storage latency.'
            FROM pg_stat_bgwriter
            UNION ALL
            SELECT 'checkpoints.write_time_ms', checkpoint_write_time::numeric, 'milliseconds', 'INFO',
                   'pg_stat_bgwriter', 'Cumulative checkpoint write time.',
                   'Use deltas to identify checkpoint write pressure.'
            FROM pg_stat_bgwriter
            UNION ALL
            SELECT 'checkpoints.sync_time_ms', checkpoint_sync_time::numeric, 'milliseconds', 'INFO',
                   'pg_stat_bgwriter', 'Cumulative checkpoint sync time.',
                   'High sync deltas can indicate storage latency.'
            FROM pg_stat_bgwriter
        $sql$;
    END IF;
END $$;

SELECT
    'step_01_instance_health_dashboard' AS report_section,
    metric_name,
    metric_value,
    unit,
    status,
    source_view,
    purpose,
    recommended_action
FROM obs360_instance_health_report
ORDER BY
    CASE status WHEN 'CRITICAL' THEN 1 WHEN 'WARN' THEN 2 WHEN 'REVIEW' THEN 3 WHEN 'INFO' THEN 4 ELSE 5 END,
    metric_name;

-- SAMPLE_OUTPUT_BEGIN
-- report_section                    | metric_name          | metric_value | unit    | status | source_view
-- ----------------------------------+----------------------+--------------+---------+--------+---------------------
-- step_01_instance_health_dashboard | locks.waiting        |            0 | count   | OK     | pg_locks
-- step_01_instance_health_dashboard | cache.hit_pct        |        99.12 | percent | OK     | pg_stat_database
-- SAMPLE_OUTPUT_END
