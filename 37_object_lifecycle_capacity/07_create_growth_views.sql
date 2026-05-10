/*
PostgreSQL DBA Script: Create Growth Views
Purpose: Create monthly growth views for objects and databases.
Area: Object Lifecycle and Capacity Monitoring
Usage: Use for month-by-month capacity tracking and growth anomaly detection.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
CREATE SCHEMA IF NOT EXISTS dba_metrics;

CREATE OR REPLACE VIEW dba_metrics.vw_object_growth_monthly AS
WITH monthly_last AS (
    SELECT
        date_trunc('month', captured_at)::date AS month_start,
        object_oid,
        schema_name,
        object_name,
        object_type,
        total_size_bytes,
        captured_at,
        row_number() OVER (
            PARTITION BY object_oid, date_trunc('month', captured_at)::date
            ORDER BY captured_at DESC
        ) AS rn
    FROM dba_metrics.object_size_snap
),
series AS (
    SELECT
        month_start,
        object_oid,
        schema_name,
        object_name,
        object_type,
        total_size_bytes,
        lag(total_size_bytes) OVER (
            PARTITION BY object_oid
            ORDER BY month_start
        ) AS prev_total_size_bytes
    FROM monthly_last
    WHERE rn = 1
)
SELECT
    month_start,
    schema_name,
    object_name,
    object_type,
    total_size_bytes,
    prev_total_size_bytes,
    (total_size_bytes - prev_total_size_bytes) AS growth_bytes,
    round(
        CASE
            WHEN prev_total_size_bytes IS NULL OR prev_total_size_bytes = 0 THEN NULL
            ELSE 100.0 * (total_size_bytes - prev_total_size_bytes)::numeric / prev_total_size_bytes
        END,
        2
    ) AS growth_pct,
    pg_size_pretty(total_size_bytes) AS total_size_pretty,
    pg_size_pretty(coalesce(total_size_bytes - prev_total_size_bytes, 0)) AS growth_pretty
FROM series;

CREATE OR REPLACE VIEW dba_metrics.vw_database_growth_monthly AS
WITH monthly_last AS (
    SELECT
        date_trunc('month', captured_at)::date AS month_start,
        database_name,
        size_bytes,
        captured_at,
        row_number() OVER (
            PARTITION BY database_name, date_trunc('month', captured_at)::date
            ORDER BY captured_at DESC
        ) AS rn
    FROM dba_metrics.database_size_snap
),
series AS (
    SELECT
        month_start,
        database_name,
        size_bytes,
        lag(size_bytes) OVER (
            PARTITION BY database_name
            ORDER BY month_start
        ) AS prev_size_bytes
    FROM monthly_last
    WHERE rn = 1
)
SELECT
    month_start,
    database_name,
    size_bytes,
    prev_size_bytes,
    (size_bytes - prev_size_bytes) AS growth_bytes,
    round(
        CASE
            WHEN prev_size_bytes IS NULL OR prev_size_bytes = 0 THEN NULL
            ELSE 100.0 * (size_bytes - prev_size_bytes)::numeric / prev_size_bytes
        END,
        2
    ) AS growth_pct,
    pg_size_pretty(size_bytes) AS size_pretty,
    pg_size_pretty(coalesce(size_bytes - prev_size_bytes, 0)) AS growth_pretty
FROM series;

SELECT
    'step_01_schema_ready' AS setup_step,
    'dba_metrics' AS object_name,
    CASE WHEN to_regnamespace('dba_metrics') IS NOT NULL THEN 'READY' ELSE 'FAILED' END AS status,
    'Schema for monthly capacity growth views.' AS purpose,
    'Continue only when status is READY.' AS next_action;

SELECT
    'step_02_dependency_check' AS setup_step,
    object_name,
    CASE WHEN to_regclass(object_name) IS NOT NULL THEN 'READY' ELSE 'MISSING' END AS status,
    purpose,
    next_action
FROM (
    VALUES
        ('dba_metrics.object_size_snap', 'Source object size snapshots for object growth.', 'If missing, run 01_create_lifecycle_repository.sql and 04_capture_snapshot_now.sql.'),
        ('dba_metrics.database_size_snap', 'Source database size snapshots for database growth.', 'If missing, run 01_create_lifecycle_repository.sql and 04_capture_snapshot_now.sql.')
) AS d(object_name, purpose, next_action)
ORDER BY object_name;

SELECT
    'step_03_view_status' AS setup_step,
    object_name,
    CASE WHEN to_regclass(object_name) IS NOT NULL THEN 'READY' ELSE 'MISSING' END AS status,
    purpose,
    next_action
FROM (
    VALUES
        ('dba_metrics.vw_object_growth_monthly', 'Monthly object growth by table, index, toast, sequence, and materialized view.', 'Use this to find storage growth drivers.'),
        ('dba_metrics.vw_database_growth_monthly', 'Monthly database growth by database.', 'Use this for capacity trend and run-rate analysis.')
) AS v(object_name, purpose, next_action)
ORDER BY object_name;

WITH db_rows AS (
    SELECT
        month_start,
        database_name,
        size_pretty,
        growth_pretty,
        growth_pct
    FROM dba_metrics.vw_database_growth_monthly
    ORDER BY month_start DESC
    LIMIT 12
)
SELECT
    'step_04_database_growth_preview' AS setup_step,
    month_start,
    database_name,
    size_pretty,
    growth_pretty,
    growth_pct,
    CASE
        WHEN growth_pct >= 25 THEN 'HIGH_GROWTH'
        WHEN growth_pct >= 10 THEN 'MEDIUM_GROWTH'
        WHEN growth_pct IS NULL THEN 'BASELINE'
        ELSE 'LOW_GROWTH'
    END AS interpretation,
    'Compare with object growth preview to identify what changed.' AS next_action
FROM db_rows
UNION ALL
SELECT
    'step_04_database_growth_preview',
    NULL::date,
    current_database(),
    NULL::text,
    NULL::text,
    NULL::numeric,
    'NO_DATA',
    'Capture snapshots before using database growth reports.'
WHERE NOT EXISTS (SELECT 1 FROM db_rows);

WITH object_rows AS (
    SELECT
        month_start,
        schema_name,
        object_name,
        object_type,
        total_size_pretty,
        growth_pretty,
        growth_pct
    FROM dba_metrics.vw_object_growth_monthly
    WHERE growth_bytes IS NOT NULL
    ORDER BY month_start DESC, growth_bytes DESC NULLS LAST
    LIMIT 20
)
SELECT
    'step_05_object_growth_preview' AS setup_step,
    month_start,
    schema_name,
    object_name,
    object_type,
    total_size_pretty,
    growth_pretty,
    growth_pct,
    CASE
        WHEN growth_pct >= 50 THEN 'HIGH_GROWTH'
        WHEN growth_pct >= 20 THEN 'MEDIUM_GROWTH'
        WHEN growth_pct IS NULL THEN 'BASELINE'
        ELSE 'LOW_GROWTH'
    END AS interpretation,
    'Review retention, partitioning, index count, and bloat for high-growth objects.' AS next_action
FROM object_rows
UNION ALL
SELECT
    'step_05_object_growth_preview',
    NULL::date,
    NULL::text,
    'NO_DATA',
    NULL::text,
    NULL::text,
    NULL::text,
    NULL::numeric,
    'NO_DATA',
    'Need at least two monthly snapshot points to calculate object growth.'
WHERE NOT EXISTS (SELECT 1 FROM object_rows);


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_37_verify_20260220_safedrop_final
--
-- CREATE SCHEMA
-- CREATE VIEW
-- CREATE VIEW
-- SAMPLE_OUTPUT_END
