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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    |     table_name     |                  index_name                  | index_bytes | index_pretty | idx_scan | recommendation 
------------------+--------------------+----------------------------------------------+-------------+--------------+----------+----------------
 perf             | payments           | payments_tenant_id_order_id_payment_ts_idx   |    66355200 | 63 MB        |        0 | Observe
 perf             | order_items        | order_items_pkey                             |    63356928 | 60 MB        |        0 | Observe
 perf             | order_items        | order_items_tenant_id_order_id_idx           |    59195392 | 56 MB        |        0 | Observe
 perf             | app_events         | app_events_pkey                              |    56172544 | 54 MB        |        0 | Observe
 perf             | orders             | orders_tenant_id_user_id_order_ts_idx        |    47792128 | 46 MB        |        0 | Observe
 perf             | app_events         | app_events_tenant_id_event_type_event_ts_idx |    22667264 | 22 MB        |        0 | Observe
 perf             | orders             | orders_pkey                                  |    21135360 | 20 MB        |        0 | Observe
 perf             | payments           | payments_pkey                                |    20709376 | 20 MB        |        0 | Observe
 perf             | app_events         | app_events_tenant_id_event_ts_idx            |    20406272 | 19 MB        |        0 | Observe
 perf             | shipments          | shipments_pkey                               |    19013632 | 18 MB        |        0 | Observe
 perf             | orders             | orders_tenant_id_order_ts_idx                |     9568256 | 9344 kB      |        0 | Observe
 perf             | inventory          | inventory_pkey                               |     3481600 | 3400 kB      |        0 | Observe
 migration_v1_lab | child_transactions | child_transactions_pkey                      |     2703360 | 2640 kB      |        0 | Observe
 perf             | product_categories | product_categories_pkey                      |     2686976 | 2624 kB      |        0 | Observe
 perf             | users              | users_tenant_id_status_created_at_idx        |     2547712 | 2488 kB      |        0 | Observe
 perf             | users              | users_pkey                                   |     2260992 | 2208 kB      |        0 | Observe
 perf             | products           | products_pkey                                |     2260992 | 2208 kB      |        0 | Observe
 perf             | addresses          | addresses_pkey                               |     1589248 | 1552 kB      |        0 | Observe
 migration_v1_lab | product_catalog    | idx_product_sku_a                            |     1581056 | 1544 kB      |        0 | Observe
 migration_v1_lab | stale_stats_table  | stale_stats_table_pkey                       |     1359872 | 1328 kB      |        0 | Observe
 perf             | sessions           | sessions_pkey                                |     1359872 | 1328 kB      |        0 | Observe
 migration_v1_lab | product_catalog    | product_catalog_pkey                         |     1138688 | 1112 kB      |        0 | Observe
 public           | demo_users         | demo_users_pkey                              |     1138688 | 1112 kB      |        0 | Observe
 migration_v1_lab | child_transactions | idx_child_transactions_account_id            |     1081344 | 1056 kB      |        0 | Observe
 migration_v1_lab | dml_bloat_table    | dml_bloat_table_pkey                         |      581632 | 568 kB       |        1 | Observe
 public           | demo_users         | demo_users_username_idx1                     |      368640 | 360 kB       |        0 | Observe
 public           | demo_users         | idx_demo_users_username                      |      368640 | 360 kB       |        0 | Observe
 public           | demo_users         | demo_users_username_idx                      |      368640 | 360 kB       |        0 | Observe
 migration_v1_lab | parent_accounts    | parent_accounts_pkey                         |      245760 | 240 kB       |   120000 | Observe
 migration_v1_lab | orders_no_pk       | orders_no_pk_pkey                            |      245760 | 240 kB       |        0 | Observe
 perf             | feature_flags      | feature_flags_pkey                           |       98304 | 96 kB        |        0 | Observe
 perf             | categories         | categories_pkey                              |       73728 | 72 kB        |        0 | Observe
 migration_v1_lab | sales_orders       | SalesOrders_pkey                             |       40960 | 40 kB        |        0 | Observe
 perf             | tenants            | tenants_pkey                                 |       16384 | 16 kB        |        0 | Observe
 perf             | support_tickets    | support_tickets_pkey                         |        8192 | 8192 bytes   |        0 | Observe
 perf             | audit_log          | audit_log_tenant_id_audit_ts_idx             |        8192 | 8192 bytes   |        0 | Observe
 perf             | documents          | documents_pkey                               |        8192 | 8192 bytes   |        0 | Observe
 perf             | audit_log          | audit_log_pkey                               |        8192 | 8192 bytes   |        0 | Observe
 perf             | documents          | documents_tenant_id_created_at_idx           |        8192 | 8192 bytes   |        0 | Observe
 perf             | ticket_comments    | ticket_comments_pkey                         |        8192 | 8192 bytes   |        0 | Observe
 perf             | notifications      | notifications_pkey                           |        8192 | 8192 bytes   |        0 | Observe
 perf             | jobs               | jobs_pkey                                    |        8192 | 8192 bytes   |        0 | Observe
 perf             | job_runs           | job_runs_pkey                                |        8192 | 8192 bytes   |        0 | Observe
(43 rows)


SAMPLE_OUTPUT_END */
