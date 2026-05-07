/*
PostgreSQL DBA Script: Index IO Hotspots
Purpose: Show indexes with the most block reads/hits to target tuning/rebuild reviews.
Area: I/O, WAL, and Checkpoints
Usage: High-read indexes may need design or maintenance review.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    indexrelname AS index_name,
    idx_blks_read,
    idx_blks_hit,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_statio_user_indexes
ORDER BY idx_blks_read DESC, idx_blks_hit DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        |            index_name             | idx_blks_read | idx_blks_hit | index_size 
-- ------------------+-------------------------+-----------------------------------+---------------+--------------+------------
--  public           | pgbench_accounts        | pgbench_accounts_pkey             |       5284549 |     48065052 | 4284 MB
--  migration_v2_lab | amount_mapping_risk     | amount_mapping_risk_pkey          |           285 |       571342 | 5296 kB
--  migration_v2_lab | customer_contact_compat | customer_contact_compat_pkey      |           249 |       299621 | 3976 kB
--  migration_v2_lab | bloat_pressure_table    | bloat_pressure_table_pkey         |           249 |       180629 | 1984 kB
--  public           | pgbench_tellers         | pgbench_tellers_pkey              |            68 |     10830598 | 888 kB
--  public           | pgbench_branches        | pgbench_branches_pkey             |            19 |     11553010 | 152 kB
--  migration_v2_lab | parent_accounts         | parent_accounts_pkey              |             2 |       599731 | 1112 kB
--  migration_v2_lab | child_events            | child_events_pkey                 |             2 |       401022 | 5496 kB
--  migration_v2_lab | stale_stats_table       | stale_stats_table_pkey            |             2 |       329876 | 3968 kB
--  migration_v1_lab | parent_accounts         | parent_accounts_pkey              |             2 |       259622 | 240 kB
--  migration_v2_lab | sales_catalog           | sales_catalog_pkey                |             2 |       239922 | 2640 kB
--  migration_v1_lab | child_transactions      | child_transactions_pkey           |             2 |       239922 | 2640 kB
--  migration_v1_lab | stale_stats_table       | stale_stats_table_pkey            |             2 |       119758 | 1328 kB
--  migration_v1_lab | product_catalog         | product_catalog_pkey              |             2 |        99731 | 1112 kB
--  migration_v2_lab | quoted_orders           | QuotedOrders_pkey                 |             2 |         9608 | 128 kB
--  migration_v2_lab | order_fact              | order_fact_pkey                   |             1 |       451847 | 6600 kB
--  migration_v2_lab | partitioned_events_2025 | partitioned_events_2025_pkey      |             1 |       104299 | 1616 kB
--  migration_v2_lab | partitioned_events_2026 | partitioned_events_2026_pkey      |             1 |        95507 | 1488 kB
--  migration_v1_lab | dml_bloat_table         | dml_bloat_table_pkey              |             1 |        49947 | 568 kB
--  migration_v1_lab | sales_orders            | SalesOrders_pkey                  |             1 |         1597 | 40 kB
--  migration_v2_lab | issue_manifest          | issue_manifest_pkey               |             1 |           12 | 16 kB
--  migration_v2_lab | order_fact              | idx_v2_order_fact_search_lower    |             1 |            1 | 14 MB
--  migration_v2_lab | order_fact              | idx_v2_order_fact_filter_key      |             1 |            1 | 2152 kB
--  migration_v1_lab | orders_no_pk            | orders_no_pk_pkey                 |             1 |            0 | 240 kB
--  migration_v1_lab | product_catalog         | idx_product_sku_a                 |             1 |            0 | 1544 kB
--  migration_v2_lab | customer_staging_no_pk  | customer_staging_no_pk_pkey       |             1 |            0 | 1328 kB
--  migration_v2_lab | child_events            | idx_v2_child_events_account_id    |             1 |            0 | 2904 kB
--  migration_v1_lab | child_transactions      | idx_child_transactions_account_id |             1 |            0 | 1056 kB
--  migration_v2_lab | sales_catalog           | idx_v2_sales_ref_a                |             1 |            0 | 3720 kB
--  migration_v2_lab | trigger_audit_demo      | trigger_audit_demo_pkey           |             0 |            0 | 8192 bytes
-- (30 rows)
-- 
-- SAMPLE_OUTPUT_END
