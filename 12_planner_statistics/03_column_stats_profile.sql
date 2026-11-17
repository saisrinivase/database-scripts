/*
PostgreSQL DBA Script: Column Stats Profile
Purpose: Inspect planner statistics profile for user-table columns.
Area: Planner and Statistics
Usage: Use for selectivity/skew analysis before tuning stats targets.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    schemaname AS schema_name,
    tablename AS table_name,
    attname AS column_name,
    null_frac,
    n_distinct,
    correlation,
    array_length(most_common_vals, 1) AS mcv_count,
    array_length(histogram_bounds, 1) AS histogram_bins
FROM pg_stats
WHERE schemaname !~ '^pg_'
  AND schemaname <> 'information_schema'
ORDER BY schemaname, tablename, attname;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |           table_name           |     column_name     | null_frac  | n_distinct  |  correlation   | mcv_count | histogram_bins 
-- ------------------+--------------------------------+---------------------+------------+-------------+----------------+-----------+----------------
--  migration_v1_lab | child_transactions             | account_id          |          0 |        9873 |   -0.006613721 |        45 |            101
--  migration_v1_lab | child_transactions             | amount              |          0 |   -0.652275 |    -0.00899792 |           |            101
--  migration_v1_lab | child_transactions             | created_at          |          0 |           1 |              1 |         1 |               
--  migration_v1_lab | child_transactions             | txn_id              |          0 |          -1 |              1 |           |            101
--  migration_v1_lab | dml_bloat_table                | id                  |          0 |          -1 |              1 |           |            101
--  migration_v1_lab | dml_bloat_table                | payload             |          0 |          -1 |                |           |               
--  migration_v1_lab | orders_no_pk                   | created_at          |          0 |           1 |              1 |         1 |               
--  migration_v1_lab | orders_no_pk                   | customer_name       |          0 |          -1 |     0.81865406 |           |            101
--  migration_v1_lab | orders_no_pk                   | order_id            |          0 |          -1 |              1 |           |            101
--  migration_v1_lab | parent_accounts                | account_id          |          0 |          -1 |              1 |           |            101
--  migration_v1_lab | parent_accounts                | account_name        |          0 |          -1 |     0.81865406 |           |            101
--  migration_v1_lab | product_catalog                | category            |          0 |           5 |     0.20723942 |         5 |               
--  migration_v1_lab | product_catalog                | created_at          |          0 |           1 |              1 |         1 |               
--  migration_v1_lab | product_catalog                | price               |          0 |    -0.57938 |  -0.0006277735 |        25 |            101
--  migration_v1_lab | product_catalog                | product_id          |          0 |          -1 |              1 |           |            101
--  migration_v1_lab | product_catalog                | sku                 |          0 |          -1 |      0.3342347 |           |            101
--  migration_v1_lab | sales_orders                   | notes               |          0 |          -1 |     0.81993854 |           |            101
--  migration_v1_lab | sales_orders                   | sales_order_id      |          0 |          -1 |              1 |           |            101
--  migration_v1_lab | stale_stats_table              | id                  |          0 |          -1 |              1 |           |            101
--  migration_v1_lab | stale_stats_table              | payload             |          0 |          -1 |     0.01151024 |           |            101
--  migration_v2_lab | amount_mapping_risk            | created_at          |          0 |           1 |              1 |         1 |               
--  migration_v2_lab | amount_mapping_risk            | id                  |          0 |          -1 |              1 |           |            101
--  migration_v2_lab | amount_mapping_risk            | source_numeric      |          0 |          -1 |     0.64158696 |           |            101
--  migration_v2_lab | amount_mapping_risk            | target_bigint_model |          0 |          -1 |     0.64158696 |           |            101
--  migration_v2_lab | amount_mapping_risk            | target_int4_model   | 0.20023334 | -0.79976666 |              1 |           |            101
--  migration_v2_lab | bloat_pressure_table           | created_at          |          0 |           1 |              1 |         1 |               
--  migration_v2_lab | bloat_pressure_table           | id                  |          0 |          -1 |              1 |           |            101
--  migration_v2_lab | bloat_pressure_table           | payload             |          0 |          -1 |                |           |               
--  migration_v2_lab | child_events                   | account_id          |          0 |   -0.174252 |  -0.0061807693 |         5 |            101
--  migration_v2_lab | child_events                   | amount              |          0 |   -0.691312 | -0.00041531035 |           |            101
--  migration_v2_lab | child_events                   | event_id            |          0 |          -1 |              1 |           |            101
--  migration_v2_lab | child_events                   | event_ts            |          0 |           1 |              1 |         1 |               
--  migration_v2_lab | child_events                   | event_type          |          0 |           3 |     0.33832195 |         3 |               
--  migration_v2_lab | customer_contact_compat        | comments            | 0.14436667 |           1 |              1 |         1 |               
--  migration_v2_lab | customer_contact_compat        | customer_id         |          0 |          -1 |     0.50398254 |           |            101
--  migration_v2_lab | customer_contact_compat        | email               | 0.25343335 | -0.74656665 |     0.38599345 |           |            101
--  migration_v2_lab | customer_contact_compat        | phone               |     0.3319 | -0.11041111 |     0.06054506 |           |            101
--  migration_v2_lab | customer_staging_no_pk         | created_at          |          0 |           1 |              1 |         1 |               
--  migration_v2_lab | customer_staging_no_pk         | customer_name       |          0 |          -1 |     0.47222167 |           |            101
--  migration_v2_lab | customer_staging_no_pk         | region_code         |          0 |           4 |     0.25118142 |         4 |               
-- ... remaining sample rows omitted; run the script for current environment-specific results.
-- SAMPLE_OUTPUT_END
