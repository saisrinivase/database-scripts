/*
PostgreSQL DBA Script: Create Observer Repository
Purpose: Create repository tables for observer-agent snapshots, findings, thresholds, and run history.
Area: Observer Agent Monitoring
Usage: Run once in a DBA utility database before scheduled observer captures.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Creates schema dba_observer and repository tables; safe to rerun.
*/
CREATE SCHEMA IF NOT EXISTS dba_observer;

CREATE TABLE IF NOT EXISTS dba_observer.observer_snapshots (
    snapshot_id bigserial PRIMARY KEY,
    captured_at timestamptz NOT NULL DEFAULT now(),
    database_name name NOT NULL DEFAULT current_database(),
    server_version text NOT NULL DEFAULT current_setting('server_version'),
    server_version_num integer NOT NULL DEFAULT current_setting('server_version_num')::integer,
    is_standby boolean NOT NULL DEFAULT pg_is_in_recovery(),
    total_connections integer,
    active_connections integer,
    idle_in_txn_connections integer,
    waiting_sessions integer,
    waiting_locks integer,
    transactions_over_15m integer,
    long_queries_over_5m integer,
    autovacuum_workers integer,
    autovacuum_backlog_tables integer,
    deadlocks numeric,
    temp_bytes numeric,
    cache_hit_pct numeric,
    wal_bytes numeric,
    wal_buffers_full numeric,
    archive_failed_count numeric,
    max_slot_retained_wal_bytes numeric,
    max_replica_lag_seconds numeric,
    max_database_xid_age numeric,
    max_table_xid_age numeric,
    health_score integer,
    status text,
    findings jsonb NOT NULL DEFAULT '[]'::jsonb,
    raw_metrics jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS observer_snapshots_captured_at_idx
    ON dba_observer.observer_snapshots (captured_at DESC);

CREATE INDEX IF NOT EXISTS observer_snapshots_status_idx
    ON dba_observer.observer_snapshots (status, captured_at DESC);

CREATE TABLE IF NOT EXISTS dba_observer.observer_findings (
    finding_id bigserial PRIMARY KEY,
    snapshot_id bigint REFERENCES dba_observer.observer_snapshots(snapshot_id) ON DELETE CASCADE,
    captured_at timestamptz NOT NULL DEFAULT now(),
    severity text NOT NULL,
    signal text NOT NULL,
    metric_name text NOT NULL,
    metric_value numeric,
    unit text,
    finding text NOT NULL,
    recommended_action text NOT NULL,
    next_script text
);

CREATE INDEX IF NOT EXISTS observer_findings_snapshot_idx
    ON dba_observer.observer_findings (snapshot_id);

CREATE INDEX IF NOT EXISTS observer_findings_severity_idx
    ON dba_observer.observer_findings (severity, captured_at DESC);

CREATE TABLE IF NOT EXISTS dba_observer.observer_metric_thresholds (
    metric_name text PRIMARY KEY,
    warn_value numeric,
    critical_value numeric,
    direction text NOT NULL CHECK (direction IN ('above','below')),
    unit text,
    purpose text,
    next_script text,
    updated_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO dba_observer.observer_metric_thresholds
    (metric_name, warn_value, critical_value, direction, unit, purpose, next_script)
VALUES
    ('connections.used_pct', 75, 90, 'above', 'percent', 'Connection saturation versus max_connections.', '14_connection_workload/01_connections_by_user_app_db.sql'),
    ('locks.waiting', 1, 1, 'above', 'count', 'Blocked lock requests.', '06_activity_locks/02_blocking_and_blocked_sessions.sql'),
    ('transactions.over_15m', 1, 5, 'above', 'count', 'Long transactions that can hold snapshots and block vacuum.', '06_activity_locks/03_long_running_transactions.sql'),
    ('queries.over_5m', 1, 5, 'above', 'count', 'Long active queries.', '18_long_queries_full_scans/01_active_long_queries.sql'),
    ('cache.hit_pct', 95, 90, 'below', 'percent', 'Low database buffer cache hit ratio.', '13_io_wal_checkpoints/01_database_io_profile.sql'),
    ('replication.max_lag_seconds', 60, 300, 'above', 'seconds', 'Streaming replica lag.', '08_replication_ha/01_primary_replication_status.sql'),
    ('slots.retained_wal_bytes', 1073741824, 10737418240, 'above', 'bytes', 'WAL retained by replication slots.', '08_replication_ha/03_replication_slots_health.sql'),
    ('xid.database_age', 1000000000, 1500000000, 'above', 'xids', 'Database XID wraparound risk.', '16_internals_deep_dive/01_database_xid_multixact_age.sql'),
    ('xid.table_age', 1000000000, 1500000000, 'above', 'xids', 'Table XID wraparound risk.', '07_vacuum_bloat/03_freeze_age_risk.sql'),
    ('archive.failed_count', 1, 1, 'above', 'count', 'WAL archiver failures.', '13_io_wal_checkpoints/04_wal_archiver_health.sql'),
    ('autovacuum.backlog_tables', 1, 10, 'above', 'count', 'Tables with vacuum/analyze backlog.', '38_observability_360/08_autovacuum_vacuum_analyze_progress.sql')
ON CONFLICT (metric_name) DO UPDATE
SET warn_value = EXCLUDED.warn_value,
    critical_value = EXCLUDED.critical_value,
    direction = EXCLUDED.direction,
    unit = EXCLUDED.unit,
    purpose = EXCLUDED.purpose,
    next_script = EXCLUDED.next_script,
    updated_at = now();

CREATE TABLE IF NOT EXISTS dba_observer.observer_run_log (
    run_id bigserial PRIMARY KEY,
    started_at timestamptz NOT NULL DEFAULT now(),
    finished_at timestamptz,
    run_type text NOT NULL,
    status text NOT NULL,
    message text
);

-- SAMPLE_OUTPUT_BEGIN
-- CREATE SCHEMA
-- CREATE TABLE
-- CREATE INDEX
-- CREATE TABLE
-- CREATE INDEX
-- CREATE TABLE
-- INSERT 0 11
-- CREATE TABLE
-- SAMPLE_OUTPUT_END
