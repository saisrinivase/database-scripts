/*
Purpose: pgAdmin-safe observer health dashboard for DBA monitoring and incident triage.
Scope: Connections, waits, locks, long transactions, vacuum blockers, XID age, temp usage, cache hit, replication, and archive risk.
pgAdmin: Safe to run in Query Tool.
Sample output:
 health_area        | status   | metric_value | unit  | diagnosis
--------------------+----------+--------------+-------+-----------------------------
 lock_waits         | warning  | 3            | count | Lock waits need blocker review.
*/

WITH settings AS (
    SELECT current_setting('max_connections')::numeric AS max_connections
),
activity AS (
    SELECT
        count(*)::numeric AS sessions,
        count(*) FILTER (WHERE state = 'active')::numeric AS active_sessions,
        count(*) FILTER (WHERE wait_event_type = 'Lock')::numeric AS lock_waiters,
        count(*) FILTER (WHERE xact_start < now() - interval '15 minutes')::numeric AS long_xacts,
        count(*) FILTER (WHERE backend_xmin IS NOT NULL AND state <> 'idle')::numeric AS xmin_holders
    FROM pg_stat_activity
),
db AS (
    SELECT
        round(100 * sum(blks_hit)::numeric / NULLIF(sum(blks_hit + blks_read), 0), 2) AS cache_hit_pct,
        round(sum(temp_bytes)::numeric / 1024 / 1024, 2) AS temp_mb,
        sum(deadlocks)::numeric AS deadlocks
    FROM pg_stat_database
),
xid AS (
    SELECT max(age(datfrozenxid))::numeric AS max_xid_age
    FROM pg_database
),
rep AS (
    SELECT coalesce(max(pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)), 0)::numeric AS max_replay_lag_bytes
    FROM pg_stat_replication
),
arch AS (
    SELECT failed_count::numeric AS archive_failures
    FROM pg_stat_archiver
)
SELECT
    'connection_headroom'::text AS health_area,
    CASE WHEN a.sessions / NULLIF(s.max_connections, 0) >= 0.9 THEN 'critical'
         WHEN a.sessions / NULLIF(s.max_connections, 0) >= 0.75 THEN 'warning'
         ELSE 'ok' END AS status,
    a.sessions AS metric_value,
    'sessions'::text AS unit,
    'Current connections versus max_connections. Check pooling and idle session control.'::text AS diagnosis
FROM activity a CROSS JOIN settings s
UNION ALL
SELECT 'active_sessions',
       CASE WHEN active_sessions > greatest(8, sessions * 0.75) THEN 'warning' ELSE 'ok' END,
       active_sessions, 'sessions',
       'High active sessions can mean CPU saturation, lock pileup, or slow SQL.'
FROM activity
UNION ALL
SELECT 'lock_waits',
       CASE WHEN lock_waiters > 0 THEN 'critical' ELSE 'ok' END,
       lock_waiters, 'sessions',
       'Lock waiters should be traced to blockers before query tuning.'
FROM activity
UNION ALL
SELECT 'long_transactions',
       CASE WHEN long_xacts > 0 THEN 'warning' ELSE 'ok' END,
       long_xacts, 'transactions',
       'Long transactions can prevent cleanup and cause bloat/XID risk.'
FROM activity
UNION ALL
SELECT 'backend_xmin_holders',
       CASE WHEN xmin_holders > 0 THEN 'warning' ELSE 'ok' END,
       xmin_holders, 'sessions',
       'backend_xmin holders can block vacuum cleanup on busy systems.'
FROM activity
UNION ALL
SELECT 'cache_hit_ratio',
       CASE WHEN cache_hit_pct < 95 THEN 'warning' ELSE 'ok' END,
       cache_hit_pct, 'percent',
       'Low cache hit ratio needs correlation with table/index scans and storage latency.'
FROM db
UNION ALL
SELECT 'temp_usage',
       CASE WHEN temp_mb > 10240 THEN 'warning' ELSE 'ok' END,
       temp_mb, 'MB',
       'Temp usage indicates sort/hash spills, large joins, or low work_mem.'
FROM db
UNION ALL
SELECT 'deadlocks',
       CASE WHEN deadlocks > 0 THEN 'warning' ELSE 'ok' END,
       deadlocks, 'count',
       'Deadlocks require transaction ordering and application workflow review.'
FROM db
UNION ALL
SELECT 'xid_age',
       CASE WHEN max_xid_age > 1500000000 THEN 'critical'
            WHEN max_xid_age > 1000000000 THEN 'warning'
            ELSE 'ok' END,
       max_xid_age, 'transactions',
       'High XID age requires freeze/vacuum action planning.'
FROM xid
UNION ALL
SELECT 'replication_lag',
       CASE WHEN max_replay_lag_bytes > 1024 * 1024 * 1024 THEN 'warning' ELSE 'ok' END,
       max_replay_lag_bytes, 'bytes',
       'Replication lag affects HA/failover data loss and read replica freshness.'
FROM rep
UNION ALL
SELECT 'archive_failures',
       CASE WHEN archive_failures > 0 THEN 'critical' ELSE 'ok' END,
       archive_failures, 'count',
       'Archive failures threaten PITR and can fill WAL storage.'
FROM arch
ORDER BY status, health_area;

-- SAMPLE_OUTPUT_BEGIN
-- health_area       | status  | metric_value | unit     | diagnosis
-- ------------------+---------+--------------+----------+------------------------------
-- lock_waits        | ok      | 0            | sessions | Lock waiters should be traced...
-- long_transactions | warning | 2            | transactions | Long transactions can prevent cleanup...
-- SAMPLE_OUTPUT_END
