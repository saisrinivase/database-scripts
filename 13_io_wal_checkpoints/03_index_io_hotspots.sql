/*
Purpose: Show indexes with the most block reads/hits to target tuning/rebuild reviews.
Area: I/O, WAL, and Checkpoints
Usage: High-read indexes may need design or maintenance review.
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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    |     table_name     |                  index_name                  | idx_blks_read | idx_blks_hit | index_size 
------------------+--------------------+----------------------------------------------+---------------+--------------+------------
 migration_v1_lab | parent_accounts    | parent_accounts_pkey                         |             1 |       259623 | 240 kB
 migration_v1_lab | child_transactions | child_transactions_pkey                      |             1 |       239923 | 2640 kB
 migration_v1_lab | stale_stats_table  | stale_stats_table_pkey                       |             1 |       119759 | 1328 kB
 migration_v1_lab | product_catalog    | product_catalog_pkey                         |             1 |        99732 | 1112 kB
 migration_v1_lab | dml_bloat_table    | dml_bloat_table_pkey                         |             1 |        49947 | 568 kB
 migration_v1_lab | sales_orders       | SalesOrders_pkey                             |             1 |         1597 | 40 kB
 migration_v1_lab | product_catalog    | idx_product_sku_a                            |             1 |            0 | 1544 kB
 migration_v1_lab | orders_no_pk       | orders_no_pk_pkey                            |             1 |            0 | 240 kB
 migration_v1_lab | child_transactions | idx_child_transactions_account_id            |             1 |            0 | 1056 kB
 perf             | app_events         | app_events_pkey                              |             0 |            0 | 54 MB
 perf             | audit_log          | audit_log_pkey                               |             0 |            0 | 8192 bytes
 perf             | documents          | documents_pkey                               |             0 |            0 | 8192 bytes
 perf             | addresses          | addresses_pkey                               |             0 |            0 | 1552 kB
 perf             | sessions           | sessions_pkey                                |             0 |            0 | 1328 kB
 perf             | feature_flags      | feature_flags_pkey                           |             0 |            0 | 96 kB
 perf             | inventory          | inventory_pkey                               |             0 |            0 | 3400 kB
 perf             | support_tickets    | support_tickets_pkey                         |             0 |            0 | 8192 bytes
 perf             | ticket_comments    | ticket_comments_pkey                         |             0 |            0 | 8192 bytes
 perf             | notifications      | notifications_pkey                           |             0 |            0 | 8192 bytes
 perf             | jobs               | jobs_pkey                                    |             0 |            0 | 8192 bytes
 perf             | job_runs           | job_runs_pkey                                |             0 |            0 | 8192 bytes
 perf             | users              | users_tenant_id_status_created_at_idx        |             0 |            0 | 2488 kB
 perf             | orders             | orders_tenant_id_order_ts_idx                |             0 |            0 | 9344 kB
 perf             | orders             | orders_tenant_id_user_id_order_ts_idx        |             0 |            0 | 46 MB
 perf             | order_items        | order_items_tenant_id_order_id_idx           |             0 |            0 | 56 MB
 perf             | payments           | payments_tenant_id_order_id_payment_ts_idx   |             0 |            0 | 63 MB
 perf             | tenants            | tenants_pkey                                 |             0 |            0 | 16 kB
 perf             | app_events         | app_events_tenant_id_event_type_event_ts_idx |             0 |            0 | 22 MB
 perf             | documents          | documents_tenant_id_created_at_idx           |             0 |            0 | 8192 bytes
 perf             | audit_log          | audit_log_tenant_id_audit_ts_idx             |             0 |            0 | 8192 bytes
 public           | demo_users         | demo_users_pkey                              |             0 |            0 | 1112 kB
 public           | demo_users         | idx_demo_users_username                      |             0 |            0 | 360 kB
 public           | demo_users         | demo_users_username_idx                      |             0 |            0 | 360 kB
 public           | demo_users         | demo_users_username_idx1                     |             0 |            0 | 360 kB
 perf             | app_events         | app_events_tenant_id_event_ts_idx            |             0 |            0 | 19 MB
 perf             | users              | users_pkey                                   |             0 |            0 | 2208 kB
 perf             | products           | products_pkey                                |             0 |            0 | 2208 kB
 perf             | categories         | categories_pkey                              |             0 |            0 | 72 kB
 perf             | product_categories | product_categories_pkey                      |             0 |            0 | 2624 kB
 perf             | orders             | orders_pkey                                  |             0 |            0 | 20 MB
 perf             | order_items        | order_items_pkey                             |             0 |            0 | 60 MB
 perf             | payments           | payments_pkey                                |             0 |            0 | 20 MB
 perf             | shipments          | shipments_pkey                               |             0 |            0 | 18 MB
(43 rows)


SAMPLE_OUTPUT_END */
