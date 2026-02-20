/*
Purpose: Create advisory views for unused indexes, high-growth objects, and high-DML pressure tables.
Area: Object Lifecycle and Capacity Monitoring
Usage: Use this as a triage queue before tuning/drop/partition decisions.
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


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_37_verify_20260220_safedrop_final
--
-- CREATE SCHEMA
-- CREATE VIEW
-- SAMPLE_OUTPUT_END
