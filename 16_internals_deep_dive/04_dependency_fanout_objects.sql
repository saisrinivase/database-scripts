/*
PostgreSQL DBA Script: Dependency Fanout Objects
Purpose: Identify objects with high dependency fanout in catalog metadata.
Area: Internals Deep Dive
Usage: High fanout objects need careful change planning.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    c.oid AS object_oid,
    n.nspname AS schema_name,
    c.relname AS object_name,
    c.relkind,
    count(d.objid) AS dependency_count
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
LEFT JOIN pg_depend d
    ON d.refobjid = c.oid
WHERE n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
GROUP BY c.oid, n.nspname, c.relname, c.relkind
ORDER BY dependency_count DESC, schema_name, object_name
LIMIT 200;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  object_oid |   schema_name    |               object_name               | relkind | dependency_count 
-- ------------+------------------+-----------------------------------------+---------+------------------
--       27603 | migration_v2_lab | order_fact                              | r       |               20
--       27514 | migration_v2_lab | child_events                            | r       |               12
--       27418 | migration_v1_lab | product_catalog                         | r       |               11
--       27533 | migration_v2_lab | sales_catalog                           | r       |               11
--       27402 | migration_v1_lab | child_transactions                      | r       |               10
--       27491 | migration_v2_lab | customer_staging_no_pk                  | r       |               10
--       27657 | migration_v2_lab | partitioned_events                      | p       |               10
--       27665 | migration_v2_lab | partitioned_events_2025                 | r       |                9
--       27675 | migration_v2_lab | partitioned_events_2026                 | r       |                9
--       27626 | migration_v2_lab | trigger_audit_demo                      | r       |                9
--       27330 | dba_metrics      | index_size_snapshots                    | r       |                8
--       27382 | migration_v1_lab | orders_no_pk                            | r       |                8
--       27572 | migration_v2_lab | bloat_pressure_table                    | r       |                8
--       27479 | migration_v2_lab | issue_manifest                          | r       |                8
--       27502 | migration_v2_lab | parent_accounts                         | r       |                8
--       27560 | migration_v2_lab | stale_stats_table                       | r       |                8
--       27320 | dba_metrics      | table_size_snapshots                    | r       |                7
--       27593 | migration_v2_lab | amount_mapping_risk                     | r       |                7
--       27549 | migration_v2_lab | quoted_orders                           | r       |                7
--       27311 | dba_metrics      | database_size_snapshots                 | r       |                6
--       27453 | migration_v1_lab | dml_bloat_table                         | r       |                6
--       27392 | migration_v1_lab | parent_accounts                         | r       |                6
--       27443 | migration_v1_lab | stale_stats_table                       | r       |                6
--       27341 | dba_metrics      | connection_snapshots                    | r       |                5
--       27434 | migration_v1_lab | sales_orders                            | r       |                5
--       27584 | migration_v2_lab | customer_contact_compat                 | r       |                5
--       27349 | dba_metrics      | wal_snapshots                           | r       |                4
--       27645 | migration_v2_lab | mv_daily_order_volume                   | m       |                3
--       25179 | public           | pgbench_accounts                        | r       |                3
--       25183 | public           | pgbench_branches                        | r       |                3
--       25175 | public           | pgbench_tellers                         | r       |                3
--       27663 | migration_v2_lab | partitioned_events_pkey                 | I       |                2
--       27641 | migration_v2_lab | vw_high_value_orders                    | v       |                2
--       25236 | public           | pg_stat_statements                      | v       |                2
--       25212 | public           | pg_stat_statements_info                 | v       |                2
--       27399 | migration_v1_lab | parent_accounts_pkey                    | i       |                1
--       27501 | migration_v2_lab | orphan_order_seq                        | S       |                1
--       27511 | migration_v2_lab | parent_accounts_pkey                    | i       |                1
--       25172 | public           | pgbench_history                         | r       |                1
--       27440 | migration_v1_lab | SalesOrders_pkey                        | i       |                0
--       27410 | migration_v1_lab | child_transactions_pkey                 | i       |                0
--       27401 | migration_v1_lab | child_transactions_txn_id_seq           | S       |                0
--       27452 | migration_v1_lab | dml_bloat_table_id_seq                  | S       |                0
--       27460 | migration_v1_lab | dml_bloat_table_pkey                    | i       |                0
--       27464 | migration_v1_lab | idx_child_transactions_account_id       | i       |                0
--       27431 | migration_v1_lab | idx_product_sku_a                       | i       |                0
--       27462 | migration_v1_lab | orders_no_pk_pkey                       | i       |                0
--       27391 | migration_v1_lab | orphan_seq                              | S       |                0
--       27429 | migration_v1_lab | product_catalog_pkey                    | i       |                0
--       27417 | migration_v1_lab | product_catalog_product_id_seq          | S       |                0
--       27433 | migration_v1_lab | sales_orders_sales_order_id_seq         | S       |                0
--       27442 | migration_v1_lab | stale_stats_table_id_seq                | S       |                0
--       27450 | migration_v1_lab | stale_stats_table_pkey                  | i       |                0
--       27557 | migration_v2_lab | QuotedOrders_pkey                       | i       |                0
--       27592 | migration_v2_lab | amount_mapping_risk_id_seq              | S       |                0
--       27600 | migration_v2_lab | amount_mapping_risk_pkey                | i       |                0
--       27571 | migration_v2_lab | bloat_pressure_table_id_seq             | S       |                0
--       27581 | migration_v2_lab | bloat_pressure_table_pkey               | i       |                0
--       27513 | migration_v2_lab | child_events_event_id_seq               | S       |                0
--       27525 | migration_v2_lab | child_events_pkey                       | i       |                0
--       27583 | migration_v2_lab | customer_contact_compat_customer_id_seq | S       |                0
--       27590 | migration_v2_lab | customer_contact_compat_pkey            | i       |                0
--       27688 | migration_v2_lab | customer_staging_no_pk_pkey             | i       |                0
--       27691 | migration_v2_lab | idx_v2_child_events_account_id          | i       |                0
--       27693 | migration_v2_lab | idx_v2_order_fact_filter_key            | i       |                0
--       27694 | migration_v2_lab | idx_v2_order_fact_search_lower          | i       |                0
--       27546 | migration_v2_lab | idx_v2_sales_ref_a                      | i       |                0
--       27489 | migration_v2_lab | issue_manifest_pkey                     | i       |                0
--       27602 | migration_v2_lab | order_fact_order_id_seq                 | S       |                0
--       27615 | migration_v2_lab | order_fact_pkey                         | i       |                0
--       27668 | migration_v2_lab | partitioned_events_2025_pkey            | i       |                0
--       27678 | migration_v2_lab | partitioned_events_2026_pkey            | i       |                0
--       27656 | migration_v2_lab | partitioned_events_event_id_seq         | S       |                0
--       27548 | migration_v2_lab | quoted_orders_quoted_order_id_seq       | S       |                0
--       27532 | migration_v2_lab | sales_catalog_catalog_id_seq            | S       |                0
--       27544 | migration_v2_lab | sales_catalog_pkey                      | i       |                0
--       27559 | migration_v2_lab | stale_stats_table_id_seq                | S       |                0
--       27569 | migration_v2_lab | stale_stats_table_pkey                  | i       |                0
--       27625 | migration_v2_lab | trigger_audit_demo_id_seq               | S       |                0
--       27635 | migration_v2_lab | trigger_audit_demo_pkey                 | i       |                0
--       25195 | public           | pgbench_accounts_pkey                   | i       |                0
--       25191 | public           | pgbench_branches_pkey                   | i       |                0
--       25193 | public           | pgbench_tellers_pkey                    | i       |                0
-- (83 rows)
-- 
-- SAMPLE_OUTPUT_END
