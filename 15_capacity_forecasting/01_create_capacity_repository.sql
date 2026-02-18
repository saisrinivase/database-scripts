/*
Purpose: Create local repository tables for periodic capacity snapshots.
Area: Capacity Forecasting
Usage: Run once in a DBA utility database before capture scripts.
*/
CREATE SCHEMA IF NOT EXISTS dba_metrics;

CREATE TABLE IF NOT EXISTS dba_metrics.database_size_snapshots (
    captured_at timestamptz NOT NULL DEFAULT now(),
    database_name text NOT NULL,
    size_bytes bigint NOT NULL
);

CREATE TABLE IF NOT EXISTS dba_metrics.table_size_snapshots (
    captured_at timestamptz NOT NULL DEFAULT now(),
    schema_name text NOT NULL,
    table_name text NOT NULL,
    total_bytes bigint NOT NULL,
    estimated_live_rows bigint,
    estimated_dead_rows bigint
);

CREATE TABLE IF NOT EXISTS dba_metrics.index_size_snapshots (
    captured_at timestamptz NOT NULL DEFAULT now(),
    schema_name text NOT NULL,
    table_name text NOT NULL,
    index_name text NOT NULL,
    index_bytes bigint NOT NULL,
    idx_scan bigint
);

CREATE TABLE IF NOT EXISTS dba_metrics.connection_snapshots (
    captured_at timestamptz NOT NULL DEFAULT now(),
    database_name text,
    user_name text,
    application_name text,
    state text,
    connection_count integer NOT NULL
);

CREATE TABLE IF NOT EXISTS dba_metrics.wal_snapshots (
    captured_at timestamptz NOT NULL DEFAULT now(),
    wal_records bigint,
    wal_fpi bigint,
    wal_bytes numeric,
    stats_reset timestamptz
);
