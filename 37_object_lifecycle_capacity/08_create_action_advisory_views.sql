/*
PostgreSQL DBA Script: Create Action Advisory Views
Purpose: Create advisory views for unused indexes, high-growth objects, and high-DML pressure tables.
Area: Object Lifecycle and Capacity Monitoring
Usage: Use this as a triage queue before tuning/drop/partition decisions.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
CREATE SCHEMA IF NOT EXISTS dba_metrics;

CREATE OR REPLACE VIEW dba_metrics.vw_capacity_action_queue AS
WITH latest_month AS (
    SELECT max(month_start) AS month_start
    FROM dba_metrics.vw_table_modifications_monthly
),
latest_table_month AS (
    SELECT m.*
    FROM dba_metrics.vw_table_modifications_monthly m
    JOIN latest_month lm
      ON lm.month_start = m.month_start
),
latest_growth_month AS (
    SELECT max(month_start) AS month_start
    FROM dba_metrics.vw_object_growth_monthly
),
latest_growth AS (
    SELECT g.*
    FROM dba_metrics.vw_object_growth_monthly g
    JOIN latest_growth_month lg
      ON lg.month_start = g.month_start
)
SELECT
    'UNUSED_LARGE_INDEX' AS finding_type,
    CASE
        WHEN i.current_index_size_bytes >= 1024::bigint * 1024 * 1024 THEN 'HIGH'
        ELSE 'MEDIUM'
    END AS severity,
    i.schema_name,
    i.table_name,
    i.index_name AS object_name,
    i.current_index_size_bytes AS metric_bytes,
    coalesce(i.days_since_last_scan, i.observation_days)::numeric AS metric_value,
    i.lifecycle_status,
    'Eligible after 45d hold. Validate with EXPLAIN (ANALYZE, BUFFERS), confirm no FK/constraint dependency, then drop in a change window.' AS recommendation
FROM dba_metrics.vw_index_lifecycle i
WHERE i.dropped_at IS NULL
  AND i.lifecycle_status IN ('NEVER_USED_30D', 'STALE_30D')
  AND i.drop_eligibility_status = 'ELIGIBLE_AFTER_REVIEW'
  AND i.current_index_size_bytes >= 64::bigint * 1024 * 1024

UNION ALL

SELECT
    'UNUSED_INDEX_BLOCKED' AS finding_type,
    'LOW' AS severity,
    i.schema_name,
    i.table_name,
    i.index_name AS object_name,
    i.current_index_size_bytes AS metric_bytes,
    coalesce(i.days_since_last_scan, i.observation_days)::numeric AS metric_value,
    i.drop_eligibility_status AS lifecycle_status,
    'Not a drop candidate under current policy; keep and review manually only if design changes.' AS recommendation
FROM dba_metrics.vw_index_lifecycle i
WHERE i.dropped_at IS NULL
  AND i.lifecycle_status IN ('NEVER_USED_30D', 'STALE_30D')
  AND i.drop_eligibility_status IN ('BLOCK_PRIMARY', 'BLOCK_CONSTRAINT', 'BLOCK_UNIQUE', 'HOLD_45D')
  AND i.current_index_size_bytes >= 64::bigint * 1024 * 1024

UNION ALL

SELECT
    'FAST_GROWING_OBJECT' AS finding_type,
    CASE
        WHEN coalesce(g.growth_bytes, 0) >= 5::bigint * 1024 * 1024 * 1024 THEN 'HIGH'
        WHEN coalesce(g.growth_bytes, 0) >= 1::bigint * 1024 * 1024 * 1024 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS severity,
    g.schema_name,
    NULL::text AS table_name,
    g.object_name,
    coalesce(g.growth_bytes, 0) AS metric_bytes,
    g.growth_pct AS metric_value,
    'MONTHLY_GROWTH' AS lifecycle_status,
    'Review retention, compression strategy, partitioning, and index design for this growth pattern.' AS recommendation
FROM latest_growth g
WHERE coalesce(g.growth_bytes, 0) > 0
  AND (coalesce(g.growth_bytes, 0) >= 1::bigint * 1024 * 1024 * 1024 OR coalesce(g.growth_pct, 0) >= 20)

UNION ALL

SELECT
    'HIGH_DML_PRESSURE_TABLE' AS finding_type,
    CASE
        WHEN t.total_dml >= 10000000 THEN 'HIGH'
        WHEN t.total_dml >= 1000000 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS severity,
    t.schema_name,
    t.table_name,
    t.table_name AS object_name,
    t.max_table_total_size_bytes AS metric_bytes,
    t.total_dml::numeric AS metric_value,
    'MONTHLY_DML' AS lifecycle_status,
    'Evaluate autovacuum thresholds, HOT update ratio, and partitioning strategy for sustained DML pressure.' AS recommendation
FROM latest_table_month t
WHERE t.total_dml >= 1000000
ORDER BY severity DESC, metric_bytes DESC NULLS LAST, metric_value DESC NULLS LAST;

SELECT
    'step_01_schema_ready' AS setup_step,
    'dba_metrics' AS object_name,
    CASE WHEN to_regnamespace('dba_metrics') IS NOT NULL THEN 'READY' ELSE 'FAILED' END AS status,
    'Schema for advisory/action queue views.' AS purpose,
    'Continue only when status is READY.' AS next_action;

SELECT
    'step_02_dependency_check' AS setup_step,
    object_name,
    CASE WHEN to_regclass(object_name) IS NOT NULL THEN 'READY' ELSE 'MISSING' END AS status,
    purpose,
    next_action
FROM (
    VALUES
        ('dba_metrics.vw_index_lifecycle', 'Source for unused/stale index advisory rows.', 'If missing, run 05_create_index_lifecycle_views.sql.'),
        ('dba_metrics.vw_object_growth_monthly', 'Source for fast-growing object advisory rows.', 'If missing, run 07_create_growth_views.sql.'),
        ('dba_metrics.vw_table_modifications_monthly', 'Source for high-DML table advisory rows.', 'If missing, run 06_create_table_modification_views.sql.')
) AS d(object_name, purpose, next_action)
ORDER BY object_name;

SELECT
    'step_03_view_status' AS setup_step,
    'dba_metrics.vw_capacity_action_queue' AS object_name,
    CASE WHEN to_regclass('dba_metrics.vw_capacity_action_queue') IS NOT NULL THEN 'READY' ELSE 'MISSING' END AS status,
    'Prioritized action queue for unused indexes, high-growth objects, and high-DML tables.' AS purpose,
    'Review HIGH first, then MEDIUM; validate before any DDL change.' AS next_action;

WITH queue_rows AS (
    SELECT
        finding_type,
        severity,
        count(*) AS finding_count,
        pg_size_pretty(sum(coalesce(metric_bytes, 0))::bigint) AS total_metric_size
    FROM dba_metrics.vw_capacity_action_queue
    GROUP BY finding_type, severity
)
SELECT
    'step_04_action_summary' AS setup_step,
    finding_type,
    severity,
    finding_count,
    round(100.0 * finding_count / nullif(sum(finding_count) OVER (), 0), 2) AS pct_of_findings,
    total_metric_size,
    CASE
        WHEN severity = 'HIGH' THEN 'Create a remediation task and review this in the monthly DBA meeting.'
        WHEN severity = 'MEDIUM' THEN 'Validate whether the trend repeats next cycle.'
        ELSE 'Keep for awareness.'
    END AS next_action
FROM queue_rows
UNION ALL
SELECT
    'step_04_action_summary',
    'NO_FINDINGS',
    'INFO',
    0,
    0.00,
    '0 bytes',
    'No current advisory rows met thresholds. Continue scheduled snapshots.'
WHERE NOT EXISTS (SELECT 1 FROM queue_rows)
ORDER BY severity, finding_type;

SELECT
    'step_05_top_actions' AS setup_step,
    finding_type,
    severity,
    schema_name,
    table_name,
    object_name,
    pg_size_pretty(metric_bytes) AS metric_size,
    metric_value,
    lifecycle_status,
    recommendation
FROM dba_metrics.vw_capacity_action_queue
ORDER BY
    CASE severity WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 ELSE 3 END,
    metric_bytes DESC NULLS LAST,
    metric_value DESC NULLS LAST
LIMIT 40;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_37_verify_20260220_safedrop_final
--
-- CREATE SCHEMA
-- CREATE VIEW
-- SAMPLE_OUTPUT_END
