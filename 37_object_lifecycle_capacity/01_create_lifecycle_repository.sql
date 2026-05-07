/*
PostgreSQL DBA Script: Create Lifecycle Repository
Purpose: Create repository tables for lifecycle events, usage snapshots, and growth tracking.
Area: Object Lifecycle and Capacity Monitoring
Usage: Run once per database before enabling scheduled captures.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
CREATE SCHEMA IF NOT EXISTS dba_metrics;

CREATE TABLE IF NOT EXISTS dba_metrics.capture_run (
    run_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    captured_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    database_name text NOT NULL DEFAULT current_database(),
    capture_source text NOT NULL DEFAULT 'manual',
    notes text
);

CREATE TABLE IF NOT EXISTS dba_metrics.ddl_event_log (
    event_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_ts timestamptz NOT NULL DEFAULT clock_timestamp(),
    event_kind text NOT NULL,
    command_tag text,
    object_type text,
    schema_name text,
    object_identity text,
    in_extension boolean,
    username text NOT NULL DEFAULT session_user,
    txid bigint,
    details jsonb
);

CREATE TABLE IF NOT EXISTS dba_metrics.index_usage_snap (
    run_id bigint NOT NULL REFERENCES dba_metrics.capture_run(run_id) ON DELETE CASCADE,
    captured_at timestamptz NOT NULL,
    database_name text NOT NULL,
    stats_reset timestamptz,
    index_oid oid NOT NULL,
    table_oid oid NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    index_name text NOT NULL,
    idx_scan bigint NOT NULL,
    idx_tup_read bigint NOT NULL,
    idx_tup_fetch bigint NOT NULL,
    index_size_bytes bigint NOT NULL,
    table_total_size_bytes bigint NOT NULL,
    is_unique boolean,
    is_primary boolean,
    is_valid boolean,
    is_ready boolean,
    is_live boolean,
    constraint_name text,
    PRIMARY KEY (run_id, index_oid)
);

CREATE TABLE IF NOT EXISTS dba_metrics.table_mod_snap (
    run_id bigint NOT NULL REFERENCES dba_metrics.capture_run(run_id) ON DELETE CASCADE,
    captured_at timestamptz NOT NULL,
    database_name text NOT NULL,
    stats_reset timestamptz,
    table_oid oid NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    n_tup_ins bigint NOT NULL,
    n_tup_upd bigint NOT NULL,
    n_tup_del bigint NOT NULL,
    n_tup_hot_upd bigint NOT NULL,
    n_live_tup bigint,
    n_dead_tup bigint,
    n_mod_since_analyze bigint,
    vacuum_count bigint,
    autovacuum_count bigint,
    analyze_count bigint,
    autoanalyze_count bigint,
    last_vacuum timestamptz,
    last_autovacuum timestamptz,
    last_analyze timestamptz,
    last_autoanalyze timestamptz,
    table_total_size_bytes bigint NOT NULL,
    PRIMARY KEY (run_id, table_oid)
);

CREATE TABLE IF NOT EXISTS dba_metrics.object_size_snap (
    run_id bigint NOT NULL REFERENCES dba_metrics.capture_run(run_id) ON DELETE CASCADE,
    captured_at timestamptz NOT NULL,
    database_name text NOT NULL,
    object_oid oid NOT NULL,
    schema_name text NOT NULL,
    object_name text NOT NULL,
    object_type text NOT NULL,
    relkind "char" NOT NULL,
    total_size_bytes bigint NOT NULL,
    relation_size_bytes bigint NOT NULL,
    toast_size_bytes bigint NOT NULL,
    index_size_bytes bigint NOT NULL,
    estimated_rows bigint,
    PRIMARY KEY (run_id, object_oid)
);

CREATE TABLE IF NOT EXISTS dba_metrics.database_size_snap (
    run_id bigint NOT NULL REFERENCES dba_metrics.capture_run(run_id) ON DELETE CASCADE,
    captured_at timestamptz NOT NULL,
    database_name text NOT NULL,
    size_bytes bigint NOT NULL,
    PRIMARY KEY (run_id, database_name)
);

CREATE TABLE IF NOT EXISTS dba_metrics.tablespace_size_snap (
    run_id bigint NOT NULL REFERENCES dba_metrics.capture_run(run_id) ON DELETE CASCADE,
    captured_at timestamptz NOT NULL,
    tablespace_name text NOT NULL,
    size_bytes bigint NOT NULL,
    PRIMARY KEY (run_id, tablespace_name)
);

CREATE TABLE IF NOT EXISTS dba_metrics.db_stats_reset_snap (
    run_id bigint NOT NULL REFERENCES dba_metrics.capture_run(run_id) ON DELETE CASCADE,
    captured_at timestamptz NOT NULL,
    database_name text NOT NULL,
    stats_reset timestamptz,
    PRIMARY KEY (run_id, database_name)
);

CREATE INDEX IF NOT EXISTS idx_ddl_event_log_object_identity
    ON dba_metrics.ddl_event_log (object_identity, event_ts DESC);

CREATE INDEX IF NOT EXISTS idx_ddl_event_log_object_type
    ON dba_metrics.ddl_event_log (object_type, event_ts DESC);

CREATE INDEX IF NOT EXISTS idx_index_usage_snap_index_oid
    ON dba_metrics.index_usage_snap (index_oid, captured_at);

CREATE INDEX IF NOT EXISTS idx_table_mod_snap_table_oid
    ON dba_metrics.table_mod_snap (table_oid, captured_at);

CREATE INDEX IF NOT EXISTS idx_object_size_snap_object_oid
    ON dba_metrics.object_size_snap (object_oid, captured_at);

CREATE INDEX IF NOT EXISTS idx_capture_run_captured_at
    ON dba_metrics.capture_run (captured_at);


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_37_verify_20260220_safedrop_final
--
-- CREATE SCHEMA
-- CREATE TABLE
-- CREATE TABLE
-- CREATE TABLE
-- CREATE TABLE
-- CREATE TABLE
-- CREATE TABLE
-- CREATE TABLE
-- CREATE TABLE
-- CREATE INDEX
-- CREATE INDEX
-- CREATE INDEX
-- CREATE INDEX
-- CREATE INDEX
-- CREATE INDEX
-- SAMPLE_OUTPUT_END
