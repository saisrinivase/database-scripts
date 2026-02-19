/*
Purpose: Highlight large indexes with low scan counts as maintenance/drop review candidates.
Area: Index Analysis
Usage: This is heuristic guidance, not an automatic drop list.
*/
SELECT
    s.schemaname AS schema_name,
    s.relname AS table_name,
    s.indexrelname AS index_name,
    pg_relation_size(s.indexrelid) AS index_bytes,
    pg_size_pretty(pg_relation_size(s.indexrelid)) AS index_pretty,
    s.idx_scan,
    CASE
        WHEN s.idx_scan = 0 AND pg_relation_size(s.indexrelid) >= 1024::bigint * 1024 * 1024
            THEN 'High priority review'
        WHEN s.idx_scan < 100 AND pg_relation_size(s.indexrelid) >= 512::bigint * 1024 * 1024
            THEN 'Medium priority review'
        ELSE 'Observe'
    END AS recommendation
FROM pg_stat_user_indexes s
ORDER BY index_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        |            index_name             | index_bytes | index_pretty | idx_scan | recommendation 
-- ------------------+-------------------------+-----------------------------------+-------------+--------------+----------+----------------
--  public           | pgbench_accounts        | pgbench_accounts_pkey             |  4492353536 | 4284 MB      | 10665646 | Observe
--  migration_v2_lab | order_fact              | idx_v2_order_fact_search_lower    |    14868480 | 14 MB        |        0 | Observe
--  migration_v2_lab | order_fact              | order_fact_pkey                   |     6758400 | 6600 kB      |        0 | Observe
--  migration_v2_lab | child_events            | child_events_pkey                 |     5627904 | 5496 kB      |        0 | Observe
--  migration_v2_lab | amount_mapping_risk     | amount_mapping_risk_pkey          |     5423104 | 5296 kB      |        0 | Observe
--  migration_v2_lab | customer_contact_compat | customer_contact_compat_pkey      |     4071424 | 3976 kB      |        0 | Observe
--  migration_v2_lab | stale_stats_table       | stale_stats_table_pkey            |     4063232 | 3968 kB      |        0 | Observe
--  migration_v2_lab | sales_catalog           | idx_v2_sales_ref_a                |     3809280 | 3720 kB      |        0 | Observe
--  migration_v2_lab | child_events            | idx_v2_child_events_account_id    |     2973696 | 2904 kB      |        0 | Observe
--  migration_v2_lab | sales_catalog           | sales_catalog_pkey                |     2703360 | 2640 kB      |        0 | Observe
--  migration_v1_lab | child_transactions      | child_transactions_pkey           |     2703360 | 2640 kB      |        0 | Observe
--  migration_v2_lab | order_fact              | idx_v2_order_fact_filter_key      |     2203648 | 2152 kB      |        0 | Observe
--  migration_v2_lab | bloat_pressure_table    | bloat_pressure_table_pkey         |     2031616 | 1984 kB      |        1 | Observe
--  migration_v2_lab | partitioned_events_2025 | partitioned_events_2025_pkey      |     1654784 | 1616 kB      |        0 | Observe
--  migration_v1_lab | product_catalog         | idx_product_sku_a                 |     1581056 | 1544 kB      |        0 | Observe
--  migration_v2_lab | partitioned_events_2026 | partitioned_events_2026_pkey      |     1523712 | 1488 kB      |        0 | Observe
--  migration_v2_lab | customer_staging_no_pk  | customer_staging_no_pk_pkey       |     1359872 | 1328 kB      |        0 | Observe
--  migration_v1_lab | stale_stats_table       | stale_stats_table_pkey            |     1359872 | 1328 kB      |        0 | Observe
--  migration_v2_lab | parent_accounts         | parent_accounts_pkey              |     1138688 | 1112 kB      |   250000 | Observe
--  migration_v1_lab | product_catalog         | product_catalog_pkey              |     1138688 | 1112 kB      |        0 | Observe
--  migration_v1_lab | child_transactions      | idx_child_transactions_account_id |     1081344 | 1056 kB      |        0 | Observe
--  public           | pgbench_tellers         | pgbench_tellers_pkey              |      909312 | 888 kB       |  5332823 | Observe
--  migration_v1_lab | dml_bloat_table         | dml_bloat_table_pkey              |      581632 | 568 kB       |        1 | Observe
--  migration_v1_lab | parent_accounts         | parent_accounts_pkey              |      245760 | 240 kB       |   120000 | Observe
--  migration_v1_lab | orders_no_pk            | orders_no_pk_pkey                 |      245760 | 240 kB       |        0 | Observe
--  public           | pgbench_branches        | pgbench_branches_pkey             |      155648 | 152 kB       |  5332823 | Observe
--  migration_v2_lab | quoted_orders           | QuotedOrders_pkey                 |      131072 | 128 kB       |        0 | Observe
--  migration_v1_lab | sales_orders            | SalesOrders_pkey                  |       40960 | 40 kB        |        0 | Observe
--  migration_v2_lab | issue_manifest          | issue_manifest_pkey               |       16384 | 16 kB        |        0 | Observe
--  migration_v2_lab | trigger_audit_demo      | trigger_audit_demo_pkey           |        8192 | 8192 bytes   |        0 | Observe
-- (30 rows)
-- 
-- SAMPLE_OUTPUT_END
