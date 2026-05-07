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


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_37_verify_20260220_safedrop_final
--
-- CREATE SCHEMA
-- CREATE VIEW
-- CREATE VIEW
-- SAMPLE_OUTPUT_END
