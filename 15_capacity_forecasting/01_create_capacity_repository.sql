/*
PostgreSQL DBA Script: Create Capacity Repository
Purpose: Create local repository tables for periodic capacity snapshots.
Area: Capacity Forecasting
Usage: Run once in a DBA utility database before capture scripts.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
-- psql:15_capacity_forecasting/01_create_capacity_repository.sql:6: NOTICE:  schema "dba_metrics" already exists, skipping
-- CREATE SCHEMA
-- psql:15_capacity_forecasting/01_create_capacity_repository.sql:12: NOTICE:  relation "database_size_snapshots" already exists, skipping
-- CREATE TABLE
-- psql:15_capacity_forecasting/01_create_capacity_repository.sql:21: NOTICE:  relation "table_size_snapshots" already exists, skipping
-- CREATE TABLE
-- psql:15_capacity_forecasting/01_create_capacity_repository.sql:30: NOTICE:  relation "index_size_snapshots" already exists, skipping
-- CREATE TABLE
-- psql:15_capacity_forecasting/01_create_capacity_repository.sql:39: NOTICE:  relation "connection_snapshots" already exists, skipping
-- CREATE TABLE
-- psql:15_capacity_forecasting/01_create_capacity_repository.sql:47: NOTICE:  relation "wal_snapshots" already exists, skipping
-- CREATE TABLE
-- SAMPLE_OUTPUT_END

