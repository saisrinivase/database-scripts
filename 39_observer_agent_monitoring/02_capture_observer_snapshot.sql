/*
PostgreSQL DBA Script: Capture Observer Snapshot
Purpose: Capture current observer metrics, score health, and store findings with recommended next scripts.
Area: Observer Agent Monitoring
Usage: Run after 01_create_observer_repository.sql; schedule every 1-5 minutes for active monitoring.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Inserts one row into dba_observer.observer_snapshots and zero or more rows into dba_observer.observer_findings.
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
sessions AS (
    SELECT
        count(*)::numeric AS total_connections,
        count(*) FILTER (WHERE state = 'active')::numeric AS active_connections,
        count(*) FILTER (WHERE state = 'idle in transaction')::numeric AS idle_in_txn_connections,
        count(*) FILTER (WHERE wait_event_type IS NOT NULL)::numeric AS waiting_sessions,
        count(*) FILTER (WHERE backend_type = 'autovacuum worker')::numeric AS autovacuum_workers,
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
        coalesce(sum(blks_hit), 0)::numeric AS blks_hit,
        coalesce(sum(blks_read), 0)::numeric AS blks_read
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
xid_db AS (
    SELECT coalesce(max(age(datfrozenxid)), 0)::numeric AS max_database_xid_age
    FROM pg_database
),
xid_table AS (
    SELECT coalesce(max(age(c.relfrozenxid)), 0)::numeric AS max_table_xid_age
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r','p','m','t')
      AND n.nspname NOT IN ('pg_catalog','information_schema')
),
vacuum_backlog AS (
    SELECT count(*)::numeric AS autovacuum_backlog_tables
    FROM pg_stat_user_tables
    WHERE (n_dead_tup > 10000 AND n_dead_tup > n_live_tup * 0.10)
       OR n_mod_since_analyze > 100000
),
metrics AS (
    SELECT
        now() AS captured_at,
        current_database()::name AS database_name,
        current_setting('server_version') AS server_version,
        current_setting('server_version_num')::integer AS server_version_num,
        pg_is_in_recovery() AS is_standby,
        s.total_connections,
        s.active_connections,
        s.idle_in_txn_connections,
        s.waiting_sessions,
        l.waiting_locks,
        s.transactions_over_15m,
        s.long_queries_over_5m,
        s.autovacuum_workers,
        vb.autovacuum_backlog_tables,
        d.deadlocks,
        d.temp_bytes,
        round(100.0 * d.blks_hit / NULLIF(d.blks_hit + d.blks_read, 0), 2) AS cache_hit_pct,
        w.wal_bytes,
        w.wal_buffers_full,
        a.archive_failed_count,
        coalesce(sl.max_slot_retained_wal_bytes, 0) AS max_slot_retained_wal_bytes,
        r.max_replica_lag_seconds,
        xd.max_database_xid_age,
        xt.max_table_xid_age,
        round(100.0 * s.total_connections / NULLIF(st.max_connections, 0), 2) AS connections_used_pct
    FROM sessions s
    CROSS JOIN settings st
    CROSS JOIN locks l
    CROSS JOIN db d
    CROSS JOIN wal w
    CROSS JOIN archiver a
    CROSS JOIN replication r
    CROSS JOIN slots sl
    CROSS JOIN xid_db xd
    CROSS JOIN xid_table xt
    CROSS JOIN vacuum_backlog vb
),
finding_rows AS (
    SELECT 'CRITICAL' AS severity, 'connection_saturation' AS signal, 'connections.used_pct' AS metric_name,
           connections_used_pct AS metric_value, 'percent' AS unit,
           'Connection usage is at or above 90% of max_connections.' AS finding,
           'Reduce connection churn, check pool sizing, and review max_connections/memory tradeoffs.' AS recommended_action,
           '14_connection_workload/01_connections_by_user_app_db.sql' AS next_script
    FROM metrics WHERE connections_used_pct >= 90
    UNION ALL
    SELECT 'WARN', 'connection_saturation', 'connections.used_pct', connections_used_pct, 'percent',
           'Connection usage is above 75% of max_connections.',
           'Review pool sizing and idle sessions before saturation.',
           '14_connection_workload/01_connections_by_user_app_db.sql'
    FROM metrics WHERE connections_used_pct >= 75 AND connections_used_pct < 90
    UNION ALL
    SELECT 'CRITICAL', 'blocking_locks', 'locks.waiting', waiting_locks, 'count',
           'One or more sessions are blocked on locks.',
           'Identify blocker/blocked chain and decide whether to tune, cancel, or terminate safely.',
           '06_activity_locks/02_blocking_and_blocked_sessions.sql'
    FROM metrics WHERE waiting_locks > 0
    UNION ALL
    SELECT 'WARN', 'transaction_hygiene', 'transactions.over_15m', transactions_over_15m, 'count',
           'Long transactions are present and can block vacuum cleanup.',
           'Find the oldest transactions and coordinate with application owners.',
           '06_activity_locks/03_long_running_transactions.sql'
    FROM metrics WHERE transactions_over_15m > 0
    UNION ALL
    SELECT 'WARN', 'long_queries', 'queries.over_5m', long_queries_over_5m, 'count',
           'Long-running active queries are present.',
           'Review waits and plans for the active long queries.',
           '18_long_queries_full_scans/01_active_long_queries.sql'
    FROM metrics WHERE long_queries_over_5m > 0
    UNION ALL
    SELECT 'REVIEW', 'cache_io', 'cache.hit_pct', cache_hit_pct, 'percent',
           'Database cache hit percentage is below 95%.',
           'Check read-heavy databases, query plans, indexes, and memory settings.',
           '13_io_wal_checkpoints/01_database_io_profile.sql'
    FROM metrics WHERE coalesce(cache_hit_pct, 100) < 95
    UNION ALL
    SELECT 'REVIEW', 'wal_pressure', 'wal.buffers_full', wal_buffers_full, 'count',
           'WAL buffers have filled before WAL writes could keep up.',
           'Review WAL generation, wal_buffers, checkpoint settings, and storage latency.',
           '13_io_wal_checkpoints/05_checkpoint_pressure_indicators.sql'
    FROM metrics WHERE wal_buffers_full > 0
    UNION ALL
    SELECT 'CRITICAL', 'archive_health', 'archive.failed_count', archive_failed_count, 'count',
           'WAL archiver failures are present.',
           'Investigate archive_command, archive destination, storage, and PITR exposure.',
           '13_io_wal_checkpoints/04_wal_archiver_health.sql'
    FROM metrics WHERE archive_failed_count > 0
    UNION ALL
    SELECT CASE WHEN max_slot_retained_wal_bytes >= 10737418240 THEN 'CRITICAL' ELSE 'WARN' END,
           'slot_wal_retention', 'slots.retained_wal_bytes', max_slot_retained_wal_bytes, 'bytes',
           'Replication slots are retaining WAL.',
           'Check inactive or lagging slots before WAL disk usage grows further.',
           '08_replication_ha/03_replication_slots_health.sql'
    FROM metrics WHERE max_slot_retained_wal_bytes >= 1073741824
    UNION ALL
    SELECT CASE WHEN max_replica_lag_seconds >= 300 THEN 'CRITICAL' ELSE 'WARN' END,
           'replication_lag', 'replication.max_lag_seconds', max_replica_lag_seconds, 'seconds',
           'Streaming replica lag is above observer threshold.',
           'Review standby receive/replay status, network, and downstream apply pressure.',
           '08_replication_ha/01_primary_replication_status.sql'
    FROM metrics WHERE max_replica_lag_seconds >= 60
    UNION ALL
    SELECT CASE WHEN max_database_xid_age >= 1500000000 THEN 'CRITICAL' ELSE 'WARN' END,
           'xid_wraparound', 'xid.database_age', max_database_xid_age, 'xids',
           'Database XID age is approaching wraparound risk thresholds.',
           'Prioritize anti-wraparound vacuum and long transaction cleanup.',
           '16_internals_deep_dive/01_database_xid_multixact_age.sql'
    FROM metrics WHERE max_database_xid_age >= 1000000000
    UNION ALL
    SELECT CASE WHEN max_table_xid_age >= 1500000000 THEN 'CRITICAL' ELSE 'WARN' END,
           'xid_wraparound', 'xid.table_age', max_table_xid_age, 'xids',
           'A table XID age is approaching wraparound risk thresholds.',
           'Find aged relations and confirm vacuum can advance relfrozenxid.',
           '07_vacuum_bloat/03_freeze_age_risk.sql'
    FROM metrics WHERE max_table_xid_age >= 1000000000
    UNION ALL
    SELECT CASE WHEN autovacuum_backlog_tables >= 10 THEN 'CRITICAL' ELSE 'WARN' END,
           'autovacuum_backlog', 'autovacuum.backlog_tables', autovacuum_backlog_tables, 'count',
           'Tables show vacuum/analyze backlog pressure.',
           'Review dead tuples, stale stats, autovacuum workers, and table-level reloptions.',
           '38_observability_360/08_autovacuum_vacuum_analyze_progress.sql'
    FROM metrics WHERE autovacuum_backlog_tables > 0
),
scored AS (
    SELECT
        m.*,
        coalesce(count(*) FILTER (WHERE f.severity = 'CRITICAL'), 0) AS critical_count,
        coalesce(count(*) FILTER (WHERE f.severity = 'WARN'), 0) AS warn_count,
        coalesce(count(*) FILTER (WHERE f.severity = 'REVIEW'), 0) AS review_count,
        coalesce(jsonb_agg(to_jsonb(f) ORDER BY
            CASE f.severity WHEN 'CRITICAL' THEN 1 WHEN 'WARN' THEN 2 ELSE 3 END,
            f.signal) FILTER (WHERE f.signal IS NOT NULL), '[]'::jsonb) AS findings_json
    FROM metrics m
    LEFT JOIN finding_rows f ON true
    GROUP BY
        m.captured_at, m.database_name, m.server_version, m.server_version_num, m.is_standby,
        m.total_connections, m.active_connections, m.idle_in_txn_connections, m.waiting_sessions,
        m.waiting_locks, m.transactions_over_15m, m.long_queries_over_5m, m.autovacuum_workers,
        m.autovacuum_backlog_tables, m.deadlocks, m.temp_bytes, m.cache_hit_pct, m.wal_bytes,
        m.wal_buffers_full, m.archive_failed_count, m.max_slot_retained_wal_bytes,
        m.max_replica_lag_seconds, m.max_database_xid_age, m.max_table_xid_age,
        m.connections_used_pct
),
insert_snapshot AS (
    INSERT INTO dba_observer.observer_snapshots (
        captured_at, database_name, server_version, server_version_num, is_standby,
        total_connections, active_connections, idle_in_txn_connections, waiting_sessions,
        waiting_locks, transactions_over_15m, long_queries_over_5m, autovacuum_workers,
        autovacuum_backlog_tables, deadlocks, temp_bytes, cache_hit_pct, wal_bytes,
        wal_buffers_full, archive_failed_count, max_slot_retained_wal_bytes,
        max_replica_lag_seconds, max_database_xid_age, max_table_xid_age,
        health_score, status, findings, raw_metrics
    )
    SELECT
        captured_at, database_name, server_version, server_version_num, is_standby,
        total_connections::integer, active_connections::integer, idle_in_txn_connections::integer,
        waiting_sessions::integer, waiting_locks::integer, transactions_over_15m::integer,
        long_queries_over_5m::integer, autovacuum_workers::integer,
        autovacuum_backlog_tables::integer, deadlocks, temp_bytes, cache_hit_pct, wal_bytes,
        wal_buffers_full, archive_failed_count, max_slot_retained_wal_bytes,
        max_replica_lag_seconds, max_database_xid_age, max_table_xid_age,
        greatest(0, 100 - critical_count::integer * 25 - warn_count::integer * 10 - review_count::integer * 5) AS health_score,
        CASE
            WHEN critical_count > 0 THEN 'CRITICAL'
            WHEN warn_count > 0 THEN 'WARN'
            WHEN review_count > 0 THEN 'REVIEW'
            ELSE 'OK'
        END AS status,
        findings_json,
        jsonb_build_object(
            'connections_used_pct', connections_used_pct,
            'critical_count', critical_count,
            'warn_count', warn_count,
            'review_count', review_count
        ) AS raw_metrics
    FROM scored
    RETURNING snapshot_id, captured_at, health_score, status
),
insert_findings AS (
    INSERT INTO dba_observer.observer_findings (
        snapshot_id, captured_at, severity, signal, metric_name, metric_value,
        unit, finding, recommended_action, next_script
    )
    SELECT
        s.snapshot_id, s.captured_at, f.severity, f.signal, f.metric_name, f.metric_value,
        f.unit, f.finding, f.recommended_action, f.next_script
    FROM insert_snapshot s
    CROSS JOIN finding_rows f
    RETURNING finding_id
)
SELECT
    s.snapshot_id,
    s.captured_at,
    s.status,
    s.health_score,
    (SELECT count(*) FROM insert_findings) AS findings_inserted
FROM insert_snapshot s;

-- SAMPLE_OUTPUT_BEGIN
-- snapshot_id | captured_at              | status | health_score | findings_inserted
-- ------------+--------------------------+--------+--------------+------------------
--          42 | 2026-05-06 13:15:00-04  | WARN   |           80 |                2
-- SAMPLE_OUTPUT_END
