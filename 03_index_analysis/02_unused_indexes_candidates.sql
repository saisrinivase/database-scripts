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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |     table_name     |            index_name             | index_bytes | index_pretty | idx_scan 
-- ------------------+--------------------+-----------------------------------+-------------+--------------+----------
--  migration_v2_lab | order_fact         | idx_v2_order_fact_search_lower    |    14868480 | 14 MB        |        0
--  migration_v2_lab | sales_catalog      | idx_v2_sales_ref_a                |     3809280 | 3720 kB      |        0
--  migration_v2_lab | child_events       | idx_v2_child_events_account_id    |     2973696 | 2904 kB      |        0
--  migration_v2_lab | order_fact         | idx_v2_order_fact_filter_key      |     2203648 | 2152 kB      |        0
--  migration_v1_lab | product_catalog    | idx_product_sku_a                 |     1581056 | 1544 kB      |        0
--  migration_v1_lab | child_transactions | idx_child_transactions_account_id |     1081344 | 1056 kB      |        0
-- (6 rows)
-- 
-- SAMPLE_OUTPUT_END
