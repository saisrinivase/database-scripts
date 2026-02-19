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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    |      table_name      |     column_name     | null_frac | n_distinct  |  correlation  | mcv_count | histogram_bins 
------------------+----------------------+---------------------+-----------+-------------+---------------+-----------+----------------
 dba_metrics      | index_size_snapshots | captured_at         |         0 |           6 |             1 |         6 |               
 dba_metrics      | index_size_snapshots | idx_scan            |         0 |           3 |    0.99750257 |         3 |               
 dba_metrics      | index_size_snapshots | index_bytes         |         0 | -0.13063063 |   0.043939825 |        29 |               
 dba_metrics      | index_size_snapshots | index_name          |         0 |  -0.1936937 |  -0.011884478 |        43 |               
 dba_metrics      | index_size_snapshots | schema_name         |         0 |           3 |    0.49125707 |         3 |               
 dba_metrics      | index_size_snapshots | table_name          |         0 | -0.13063063 |   0.017952027 |        29 |               
 dba_metrics      | table_size_snapshots | captured_at         |         0 |           5 |             1 |         5 |               
 dba_metrics      | table_size_snapshots | estimated_dead_rows |         0 |           1 |             1 |         1 |               
 dba_metrics      | table_size_snapshots | estimated_live_rows |         0 | -0.18309858 |    0.80711704 |         4 |             22
 dba_metrics      | table_size_snapshots | schema_name         |         0 |           4 |    0.52455515 |         4 |               
 dba_metrics      | table_size_snapshots | table_name          |         0 | -0.23943663 | -0.0046710856 |        27 |              7
 dba_metrics      | table_size_snapshots | total_bytes         |         0 | -0.18309858 |    0.19855152 |        19 |              7
 migration_v1_lab | child_transactions   | account_id          |         0 |        9845 | -0.0038502645 |        30 |            101
 migration_v1_lab | child_transactions   | amount              |         0 | -0.65730834 |  -0.004863798 |           |            101
 migration_v1_lab | child_transactions   | created_at          |         0 |           1 |             1 |         1 |               
 migration_v1_lab | child_transactions   | txn_id              |         0 |          -1 |             1 |           |            101
 migration_v1_lab | dml_bloat_table      | id                  |         0 |          -1 |             1 |           |            101
 migration_v1_lab | dml_bloat_table      | payload             |         0 |          -1 |               |           |               
 migration_v1_lab | orders_no_pk         | created_at          |         0 |           1 |             1 |         1 |               
 migration_v1_lab | orders_no_pk         | customer_name       |         0 |          -1 |    0.81865406 |           |            101
 migration_v1_lab | orders_no_pk         | order_id            |         0 |          -1 |             1 |           |            101
 migration_v1_lab | parent_accounts      | account_id          |         0 |          -1 |             1 |           |            101
 migration_v1_lab | parent_accounts      | account_name        |         0 |          -1 |    0.81865406 |           |            101
 migration_v1_lab | product_catalog      | category            |         0 |           5 |    0.19659315 |         5 |               
 migration_v1_lab | product_catalog      | created_at          |         0 |           1 |             1 |         1 |               
 migration_v1_lab | product_catalog      | price               |         0 |    -0.57858 |   -0.00970813 |        23 |            101
 migration_v1_lab | product_catalog      | product_id          |         0 |          -1 |             1 |           |            101
 migration_v1_lab | product_catalog      | sku                 |         0 |          -1 |    0.33704707 |           |            101
 migration_v1_lab | sales_orders         | notes               |         0 |          -1 |    0.81993854 |           |            101
 migration_v1_lab | sales_orders         | sales_order_id      |         0 |          -1 |             1 |           |            101
 migration_v1_lab | stale_stats_table    | id                  |         0 |          -1 |             1 |           |            101
 migration_v1_lab | stale_stats_table    | payload             |         0 |          -1 |  -0.002051075 |           |            101
 public           | demo_users           | id                  |         0 |          -1 |             1 |           |            101
 public           | demo_users           | username            |         0 |           3 |    0.33481345 |         3 |               
(34 rows)


SAMPLE_OUTPUT_END */
