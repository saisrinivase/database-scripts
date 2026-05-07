/*
PostgreSQL DBA Script: SLA Risk Dashboard
Purpose: Summarize live availability, latency, throughput, recoverability, and maintenance risks.
Area: Observer Agent Monitoring
Usage: Run for an executive/SME view of whether the database is at service-level risk.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Uses SQL-visible risk signals only.
*/
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
archiver AS (
    SELECT failed_count::numeric AS archive_failed_count
    FROM pg_stat_archiver
),
replication AS (
    SELECT coalesce(max(extract(epoch FROM replay_lag)), 0)::numeric AS max_replica_lag_seconds
    FROM pg_stat_replication
),
xid AS (
    SELECT coalesce(max(age(datfrozenxid)), 0)::numeric AS max_database_xid_age
    FROM pg_database
),
vacuum_backlog AS (
    SELECT count(*)::numeric AS autovacuum_backlog_tables
    FROM pg_stat_user_tables
    WHERE (n_dead_tup > 10000 AND n_dead_tup > n_live_tup * 0.10)
       OR n_mod_since_analyze > 100000
),
metrics AS (
    SELECT
        round(100.0 * s.total_connections / NULLIF(st.max_connections, 0), 2) AS connections_used_pct,
        s.active_connections,
        s.idle_in_txn_connections,
        s.waiting_sessions,
        s.transactions_over_15m,
        s.long_queries_over_5m,
        l.waiting_locks,
        d.deadlocks,
        d.temp_bytes,
        d.cache_hit_pct,
        a.archive_failed_count,
        r.max_replica_lag_seconds,
        x.max_database_xid_age,
        vb.autovacuum_backlog_tables
    FROM sessions s
    CROSS JOIN settings st
    CROSS JOIN locks l
    CROSS JOIN db d
    CROSS JOIN archiver a
    CROSS JOIN replication r
    CROSS JOIN xid x
    CROSS JOIN vacuum_backlog vb
)
SELECT *
FROM (
    SELECT 'availability' AS risk_domain,
           greatest(connections_used_pct, waiting_locks * 100) AS risk_value,
           CASE WHEN waiting_locks > 0 OR connections_used_pct >= 90 THEN 'CRITICAL'
                WHEN connections_used_pct >= 75 THEN 'WARN'
                ELSE 'OK' END AS risk_status,
           'Connection saturation or blocking locks can make the service unavailable.' AS why_it_matters,
           '38_observability_360/01_instance_health_360_dashboard.sql' AS next_script
    FROM metrics
    UNION ALL
    SELECT 'latency',
           greatest(waiting_sessions, long_queries_over_5m),
           CASE WHEN long_queries_over_5m > 0 OR waiting_sessions > 0 THEN 'WARN' ELSE 'OK' END,
           'Waits and long queries increase user-facing latency.',
           '39_observer_agent_monitoring/05_wait_lock_io_wal_classifier.sql'
    FROM metrics
    UNION ALL
    SELECT 'throughput',
           coalesce(cache_hit_pct, 100),
           CASE WHEN coalesce(cache_hit_pct, 100) < 90 THEN 'CRITICAL'
                WHEN coalesce(cache_hit_pct, 100) < 95 THEN 'REVIEW'
                ELSE 'OK' END,
           'Low cache hit or heavy temp usage can reduce throughput.',
           '13_io_wal_checkpoints/01_database_io_profile.sql'
    FROM metrics
    UNION ALL
    SELECT 'recoverability',
           greatest(archive_failed_count, max_replica_lag_seconds),
           CASE WHEN archive_failed_count > 0 OR max_replica_lag_seconds >= 300 THEN 'CRITICAL'
                WHEN max_replica_lag_seconds >= 60 THEN 'WARN'
                ELSE 'OK' END,
           'Archive failures and replica lag affect PITR/RPO posture.',
           '30_backup_restore_pitr_dr/01_backup_pitr_configuration_health.sql'
    FROM metrics
    UNION ALL
    SELECT 'maintenance',
           greatest(transactions_over_15m, autovacuum_backlog_tables),
           CASE WHEN autovacuum_backlog_tables >= 10 THEN 'CRITICAL'
                WHEN autovacuum_backlog_tables > 0 OR transactions_over_15m > 0 THEN 'WARN'
                ELSE 'OK' END,
           'Vacuum/analyze backlog and long transactions increase bloat and wraparound risk.',
           '38_observability_360/08_autovacuum_vacuum_analyze_progress.sql'
    FROM metrics
    UNION ALL
    SELECT 'data_health',
           max_database_xid_age,
           CASE WHEN max_database_xid_age >= 1500000000 THEN 'CRITICAL'
                WHEN max_database_xid_age >= 1000000000 THEN 'WARN'
                ELSE 'OK' END,
           'High XID age can become an outage-level wraparound risk.',
           '16_internals_deep_dive/01_database_xid_multixact_age.sql'
    FROM metrics
) r
ORDER BY
    CASE risk_status WHEN 'CRITICAL' THEN 1 WHEN 'WARN' THEN 2 WHEN 'REVIEW' THEN 3 ELSE 4 END,
    risk_domain;

-- SAMPLE_OUTPUT_BEGIN
-- risk_domain   | risk_value | risk_status | why_it_matters
-- --------------+------------+-------------+-------------------------------------------------
-- availability  |        100 | CRITICAL    | Connection saturation or blocking locks...
-- maintenance   |          3 | WARN        | Vacuum/analyze backlog and long transactions...
-- SAMPLE_OUTPUT_END
