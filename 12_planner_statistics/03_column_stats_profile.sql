/*
Purpose: Inspect planner statistics profile for user-table columns.
Area: Planner and Statistics
Usage: Use for selectivity/skew analysis before tuning stats targets.
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
--  migration_v2_lab | customer_staging_no_pk         | staging_id          |          0 |          -1 |              1 |           |            101
--  migration_v2_lab | idx_v2_order_fact_search_lower | lower               |          0 |          -1 |     -0.1133381 |           |            101
--  migration_v2_lab | order_fact                     | account_id          |          0 | -0.14949334 |   0.0013624388 |         2 |            101
--  migration_v2_lab | order_fact                     | created_at          |          0 |           1 |              1 |         1 |               
--  migration_v2_lab | order_fact                     | filter_key          |          0 |         201 |    0.014481727 |         4 |            101
--  migration_v2_lab | order_fact                     | order_amount        |          0 | -0.51697665 |   0.0030667118 |           |            101
--  migration_v2_lab | order_fact                     | order_id            |          0 |          -1 |              1 |           |            101
--  migration_v2_lab | order_fact                     | search_text         |          0 |          -1 |     -0.1133381 |           |            101
--  migration_v2_lab | parent_accounts                | account_id          |          0 |          -1 |              1 |           |            101
--  migration_v2_lab | parent_accounts                | account_name        |          0 |          -1 |     0.33519965 |           |            101
--  migration_v2_lab | parent_accounts                | created_at          |          0 |           1 |              1 |         1 |               
--  migration_v2_lab | partitioned_events             | event_date          |          0 |         700 |      0.7481357 |         6 |            101
--  migration_v2_lab | partitioned_events             | event_id            |          0 |          -1 |      0.5049937 |           |            101
--  migration_v2_lab | partitioned_events             | event_payload       |          0 |          -1 |   0.0019056684 |           |            101
--  migration_v2_lab | partitioned_events_2025        | event_date          |          0 |         365 |    0.009016585 |         4 |            101
--  migration_v2_lab | partitioned_events_2025        | event_id            |          0 |          -1 |              1 |           |            101
--  migration_v2_lab | partitioned_events_2025        | event_payload       |          0 |          -1 |   0.0064500035 |           |            101
--  migration_v2_lab | partitioned_events_2026        | event_date          |          0 |         335 |    0.008031925 |         4 |            101
--  migration_v2_lab | partitioned_events_2026        | event_id            |          0 |          -1 |              1 |           |            101
--  migration_v2_lab | partitioned_events_2026        | event_payload       |          0 |          -1 |   -0.002655634 |           |            101
--  migration_v2_lab | quoted_orders                  | created_at          |          0 |           1 |              1 |         1 |               
--  migration_v2_lab | quoted_orders                  | notes               |          0 |          -1 |     0.33563375 |           |            101
--  migration_v2_lab | quoted_orders                  | quoted_order_id     |          0 |          -1 |              1 |           |            101
--  migration_v2_lab | sales_catalog                  | catalog_id          |          0 |          -1 |              1 |           |            101
--  migration_v2_lab | sales_catalog                  | created_at          |          0 |           1 |              1 |         1 |               
--  migration_v2_lab | sales_catalog                  | item_ref            |          0 |          -1 |      0.0865117 |           |            101
--  migration_v2_lab | sales_catalog                  | item_type           |          0 |           5 |     0.20006078 |         5 |               
--  migration_v2_lab | sales_catalog                  | price               |          0 | -0.39419165 |  -0.0034604983 |           |            101
--  migration_v2_lab | stale_stats_table              | created_at          |          0 |           1 |              1 |         1 |               
--  migration_v2_lab | stale_stats_table              | id                  |          0 |          -1 |              1 |           |            101
--  migration_v2_lab | stale_stats_table              | payload             |          0 |          -1 |  -0.0018029535 |           |            101
--  public           | pgbench_accounts               | abalance            |          0 |           1 |              1 |         1 |               
--  public           | pgbench_accounts               | aid                 |          0 |          -1 |              1 |           |            101
--  public           | pgbench_accounts               | bid                 |          0 |        2000 |              1 |       100 |            101
--  public           | pgbench_accounts               | filler              |          0 |           1 |              1 |         1 |               
--  public           | pgbench_branches               | bbalance            |          0 |      -0.999 |    -0.05397778 |         2 |            101
--  public           | pgbench_branches               | bid                 |          0 |          -1 |   0.0007009847 |           |            101
--  public           | pgbench_branches               | filler              |          1 |           0 |                |           |               
--  public           | pgbench_history                | aid                 |          0 |   -0.965769 |   0.0030801361 |           |            101
--  public           | pgbench_history                | bid                 |          0 |        2000 |   -0.009245613 |         5 |            101
--  public           | pgbench_history                | delta               |          0 |       10019 |  -0.0010061931 |         9 |            101
--  public           | pgbench_history                | filler              |          1 |           0 |                |           |               
--  public           | pgbench_history                | mtime               |          0 |  -0.9548721 |      0.9994848 |           |            101
--  public           | pgbench_history                | tid                 |          0 |       19981 |   0.0005749439 |         2 |            101
--  public           | pgbench_tellers                | bid                 |          0 |        2000 |    0.053867284 |       100 |            101
--  public           | pgbench_tellers                | filler              |          1 |           0 |                |           |               
--  public           | pgbench_tellers                | tbalance            |          0 |    -0.94205 |   0.0055887117 |       100 |            101
--  public           | pgbench_tellers                | tid                 |          0 |          -1 |     0.05342347 |           |            101
-- (88 rows)
-- 
-- SAMPLE_OUTPUT_END
