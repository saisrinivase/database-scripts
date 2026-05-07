/*
PostgreSQL DBA Script: Active Incident Detector
Purpose: Detect current performance incidents from live PostgreSQL metrics without requiring stored snapshots.
Area: Observer Agent Monitoring
Usage: Run during an active incident to get severity, likely issue, next action, and next script.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Uses live pg_stat_activity, pg_locks, pg_stat_database, pg_stat_wal, pg_stat_archiver, pg_replication_slots, and pg_stat_replication.
*/
WITH
settings AS (
    SELECT current_setting('max_connections')::numeric AS max_connections
),
wal_position AS (
    SELECT CASE
             WHEN pg_is_in_recovery() THEN pg_last_wal_receive_lsn()
             ELSE pg_current_wal_lsn()
           END AS current_lsn
),
metrics AS (
    SELECT
        count(*)::numeric AS total_connections,
        count(*) FILTER (WHERE state = 'active')::numeric AS active_connections,
        count(*) FILTER (WHERE wait_event_type IS NOT NULL)::numeric AS waiting_sessions,
        count(*) FILTER (WHERE state = 'idle in transaction')::numeric AS idle_in_txn_connections,
        count(*) FILTER (WHERE xact_start IS NOT NULL AND now() - xact_start > interval '15 minutes')::numeric AS transactions_over_15m,
        count(*) FILTER (WHERE state = 'active' AND query_start IS NOT NULL AND now() - query_start > interval '5 minutes')::numeric AS long_queries_over_5m
    FROM pg_stat_activity
),
locks AS (
    SELECT count(*) FILTER (WHERE NOT granted)::numeric AS waiting_locks
    FROM pg_locks
),
db AS (
    SELECT
        coalesce(sum(deadlocks), 0)::numeric AS deadlocks,
        coalesce(sum(temp_bytes), 0)::numeric AS temp_bytes,
        round(100.0 * coalesce(sum(blks_hit), 0) / NULLIF(coalesce(sum(blks_hit), 0) + coalesce(sum(blks_read), 0), 0), 2) AS cache_hit_pct
    FROM pg_stat_database
    WHERE datname NOT IN ('template0', 'template1')
),
wal AS (
    SELECT wal_bytes::numeric, wal_buffers_full::numeric
    FROM pg_stat_wal
),
archiver AS (
    SELECT failed_count::numeric AS archive_failed_count
    FROM pg_stat_archiver
),
replication AS (
    SELECT coalesce(max(extract(epoch FROM replay_lag)), 0)::numeric AS max_replica_lag_seconds
    FROM pg_stat_replication
),
slots AS (
    SELECT coalesce(max(pg_wal_lsn_diff(wp.current_lsn, s.restart_lsn)), 0)::numeric AS max_slot_retained_wal_bytes
    FROM pg_replication_slots s
    CROSS JOIN wal_position wp
    WHERE s.restart_lsn IS NOT NULL
      AND wp.current_lsn IS NOT NULL
),
xid AS (
    SELECT
        (SELECT coalesce(max(age(datfrozenxid)), 0)::numeric FROM pg_database) AS max_database_xid_age,
        (SELECT coalesce(max(age(c.relfrozenxid)), 0)::numeric
         FROM pg_class c
         JOIN pg_namespace n ON n.oid = c.relnamespace
         WHERE c.relkind IN ('r','p','m','t')
           AND n.nspname NOT IN ('pg_catalog','information_schema')) AS max_table_xid_age
),
vacuum_backlog AS (
    SELECT count(*)::numeric AS autovacuum_backlog_tables
    FROM pg_stat_user_tables
    WHERE (n_dead_tup > 10000 AND n_dead_tup > n_live_tup * 0.10)
       OR n_mod_since_analyze > 100000
),
all_metrics AS (
    SELECT
        m.*,
        round(100.0 * m.total_connections / NULLIF(s.max_connections, 0), 2) AS connections_used_pct,
        l.waiting_locks,
        d.deadlocks,
        d.temp_bytes,
        d.cache_hit_pct,
        w.wal_bytes,
        w.wal_buffers_full,
        a.archive_failed_count,
        r.max_replica_lag_seconds,
        coalesce(sl.max_slot_retained_wal_bytes, 0) AS max_slot_retained_wal_bytes,
        x.max_database_xid_age,
        x.max_table_xid_age,
        vb.autovacuum_backlog_tables
    FROM metrics m
    CROSS JOIN settings s
    CROSS JOIN locks l
    CROSS JOIN db d
    CROSS JOIN wal w
    CROSS JOIN archiver a
    CROSS JOIN replication r
    CROSS JOIN slots sl
    CROSS JOIN xid x
    CROSS JOIN vacuum_backlog vb
)
SELECT *
FROM (
    SELECT 'CRITICAL' AS severity, 'blocking_locks' AS incident_type, 'locks.waiting' AS metric_name, waiting_locks AS metric_value,
           'Blocked lock requests are active.' AS evidence,
           'Identify blockers immediately; cancel/terminate only after confirming business impact.' AS recommended_action,
           '06_activity_locks/02_blocking_and_blocked_sessions.sql' AS next_script
    FROM all_metrics WHERE waiting_locks > 0
    UNION ALL
    SELECT 'CRITICAL', 'archive_failure', 'archive.failed_count', archive_failed_count,
           'WAL archiver failures are present.',
           'Protect PITR first: inspect archive destination, permissions, command, and storage.',
           '13_io_wal_checkpoints/04_wal_archiver_health.sql'
    FROM all_metrics WHERE archive_failed_count > 0
    UNION ALL
    SELECT CASE WHEN connections_used_pct >= 90 THEN 'CRITICAL' ELSE 'WARN' END,
           'connection_saturation', 'connections.used_pct', connections_used_pct,
           'Connection usage is high versus max_connections.',
           'Check pooler/app connection behavior and idle sessions.',
           '14_connection_workload/01_connections_by_user_app_db.sql'
    FROM all_metrics WHERE connections_used_pct >= 75
    UNION ALL
    SELECT 'WARN', 'transaction_hygiene', 'transactions.over_15m', transactions_over_15m,
           'Long transactions can block vacuum and cause bloat.',
           'Find oldest transactions and application owners.',
           '06_activity_locks/03_long_running_transactions.sql'
    FROM all_metrics WHERE transactions_over_15m > 0
    UNION ALL
    SELECT 'WARN', 'long_queries', 'queries.over_5m', long_queries_over_5m,
           'Long active queries are running.',
           'Check wait events and execution plans for the long queries.',
           '18_long_queries_full_scans/01_active_long_queries.sql'
    FROM all_metrics WHERE long_queries_over_5m > 0
    UNION ALL
    SELECT CASE WHEN max_slot_retained_wal_bytes >= 10737418240 THEN 'CRITICAL' ELSE 'WARN' END,
           'slot_wal_retention', 'slots.retained_wal_bytes', max_slot_retained_wal_bytes,
           'Replication slots are retaining WAL.',
           'Check inactive logical/physical slots and downstream consumers.',
           '08_replication_ha/03_replication_slots_health.sql'
    FROM all_metrics WHERE max_slot_retained_wal_bytes >= 1073741824
    UNION ALL
    SELECT CASE WHEN max_replica_lag_seconds >= 300 THEN 'CRITICAL' ELSE 'WARN' END,
           'replication_lag', 'replication.max_lag_seconds', max_replica_lag_seconds,
           'Replica lag is above observer threshold.',
           'Check standby replay, receiver status, network, and write pressure.',
           '38_observability_360/09_replication_and_slot_dashboard.sql'
    FROM all_metrics WHERE max_replica_lag_seconds >= 60
    UNION ALL
    SELECT CASE WHEN max_database_xid_age >= 1500000000 THEN 'CRITICAL' ELSE 'WARN' END,
           'xid_wraparound', 'xid.database_age', max_database_xid_age,
           'Database XID age is high.',
           'Prioritize wraparound prevention and long transaction cleanup.',
           '16_internals_deep_dive/01_database_xid_multixact_age.sql'
    FROM all_metrics WHERE max_database_xid_age >= 1000000000
    UNION ALL
    SELECT CASE WHEN autovacuum_backlog_tables >= 10 THEN 'CRITICAL' ELSE 'WARN' END,
           'autovacuum_backlog', 'autovacuum.backlog_tables', autovacuum_backlog_tables,
           'Vacuum/analyze backlog tables are present.',
           'Review autovacuum workers, table reloptions, dead tuples, and stale statistics.',
           '38_observability_360/08_autovacuum_vacuum_analyze_progress.sql'
    FROM all_metrics WHERE autovacuum_backlog_tables > 0
) incidents
ORDER BY
    CASE severity WHEN 'CRITICAL' THEN 1 WHEN 'WARN' THEN 2 ELSE 3 END,
    incident_type;

-- SAMPLE_OUTPUT_BEGIN
-- severity | incident_type       | metric_name              | metric_value | evidence
-- ---------+---------------------+--------------------------+--------------+------------------------------------------
-- CRITICAL | blocking_locks      | locks.waiting            |            2 | Blocked lock requests are active.
-- WARN     | transaction_hygiene | transactions.over_15m    |            1 | Long transactions can block vacuum...
-- SAMPLE_OUTPUT_END
