/*
PostgreSQL DBA Script: Monthly Capacity Report
Purpose: Produce a monthly DBA report for database growth, object growth, and action queue.
Area: Object Lifecycle and Capacity Monitoring
Usage: Run monthly after regular snapshots are collected.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    month_start,
    database_name,
    size_pretty,
    growth_pretty,
    growth_pct
FROM dba_metrics.vw_database_growth_monthly
ORDER BY month_start DESC
LIMIT 12;

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
ORDER BY month_start DESC, growth_bytes DESC
LIMIT 30;

SELECT
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
LIMIT 40;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_37_verify_20260220_safedrop_final
--
--  month_start | database_name | size_pretty | growth_pretty | growth_pct 
-- -------------+---------------+-------------+---------------+------------
--  2026-02-01  | pgbench_test  | 35 GB       | 0 bytes       |           
-- (1 row)
-- 
--  month_start | schema_name | object_name | object_type | total_size_pretty | growth_pretty | growth_pct 
-- -------------+-------------+-------------+-------------+-------------------+---------------+------------
-- (0 rows)
-- 
--  finding_type | severity | schema_name | table_name | object_name | metric_size | metric_value | lifecycle_status | recommendation 
-- --------------+----------+-------------+------------+-------------+-------------+--------------+------------------+----------------
-- (0 rows)
-- 
-- SAMPLE_OUTPUT_END
