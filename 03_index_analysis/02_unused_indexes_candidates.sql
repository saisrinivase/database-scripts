/*
Purpose: Identify non-unique/non-primary indexes that have never been scanned.
Area: Index Analysis
Usage: Review manually before dropping; low-traffic windows may hide infrequent use.
*/
SELECT
    s.schemaname AS schema_name,
    s.relname AS table_name,
    s.indexrelname AS index_name,
    pg_relation_size(s.indexrelid) AS index_bytes,
    pg_size_pretty(pg_relation_size(s.indexrelid)) AS index_pretty,
    s.idx_scan
FROM pg_stat_user_indexes s
JOIN pg_index i
    ON i.indexrelid = s.indexrelid
WHERE s.idx_scan = 0
  AND NOT i.indisunique
  AND NOT i.indisprimary
ORDER BY index_bytes DESC;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    |     table_name     |                  index_name                  | index_bytes | index_pretty | idx_scan 
------------------+--------------------+----------------------------------------------+-------------+--------------+----------
 perf             | payments           | payments_tenant_id_order_id_payment_ts_idx   |    66355200 | 63 MB        |        0
 perf             | order_items        | order_items_tenant_id_order_id_idx           |    59195392 | 56 MB        |        0
 perf             | orders             | orders_tenant_id_user_id_order_ts_idx        |    47792128 | 46 MB        |        0
 perf             | app_events         | app_events_tenant_id_event_type_event_ts_idx |    22667264 | 22 MB        |        0
 perf             | app_events         | app_events_tenant_id_event_ts_idx            |    20406272 | 19 MB        |        0
 perf             | orders             | orders_tenant_id_order_ts_idx                |     9568256 | 9344 kB      |        0
 perf             | users              | users_tenant_id_status_created_at_idx        |     2547712 | 2488 kB      |        0
 migration_v1_lab | product_catalog    | idx_product_sku_a                            |     1581056 | 1544 kB      |        0
 migration_v1_lab | child_transactions | idx_child_transactions_account_id            |     1081344 | 1056 kB      |        0
 public           | demo_users         | idx_demo_users_username                      |      368640 | 360 kB       |        0
 public           | demo_users         | demo_users_username_idx                      |      368640 | 360 kB       |        0
 public           | demo_users         | demo_users_username_idx1                     |      368640 | 360 kB       |        0
 perf             | audit_log          | audit_log_tenant_id_audit_ts_idx             |        8192 | 8192 bytes   |        0
 perf             | documents          | documents_tenant_id_created_at_idx           |        8192 | 8192 bytes   |        0
(14 rows)


SAMPLE_OUTPUT_END */
