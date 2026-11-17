/*
PostgreSQL DBA Script: Relation Filenode Mapping
Purpose: Map logical relation names to relfilenode and tablespace internals.
Area: Internals Deep Dive
Usage: Useful for low-level storage troubleshooting.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS relation_name,
    c.relkind,
    c.oid AS relation_oid,
    pg_relation_filenode(c.oid) AS relfilenode,
    c.reltablespace,
    pg_relation_filepath(c.oid) AS relation_filepath
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY n.nspname, c.relname;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |              relation_name              | relkind | relation_oid | relfilenode | reltablespace | relation_filepath 
-- ------------------+-----------------------------------------+---------+--------------+-------------+---------------+-------------------
--  dba_metrics      | connection_snapshots                    | r       |        27341 |       27341 |             0 | base/25171/27341
--  dba_metrics      | database_size_snapshots                 | r       |        27311 |       27311 |             0 | base/25171/27311
--  dba_metrics      | index_size_snapshots                    | r       |        27330 |       27330 |             0 | base/25171/27330
--  dba_metrics      | table_size_snapshots                    | r       |        27320 |       27320 |             0 | base/25171/27320
--  dba_metrics      | wal_snapshots                           | r       |        27349 |       27349 |             0 | base/25171/27349
--  migration_v1_lab | SalesOrders_pkey                        | i       |        27440 |       27440 |             0 | base/25171/27440
--  migration_v1_lab | child_transactions                      | r       |        27402 |       27402 |             0 | base/25171/27402
--  migration_v1_lab | child_transactions_pkey                 | i       |        27410 |       27410 |             0 | base/25171/27410
--  migration_v1_lab | child_transactions_txn_id_seq           | S       |        27401 |       27401 |             0 | base/25171/27401
--  migration_v1_lab | dml_bloat_table                         | r       |        27453 |       27453 |             0 | base/25171/27453
--  migration_v1_lab | dml_bloat_table_id_seq                  | S       |        27452 |       27452 |             0 | base/25171/27452
--  migration_v1_lab | dml_bloat_table_pkey                    | i       |        27460 |       27460 |             0 | base/25171/27460
--  migration_v1_lab | idx_child_transactions_account_id       | i       |        27464 |       27464 |             0 | base/25171/27464
--  migration_v1_lab | idx_product_sku_a                       | i       |        27431 |       27431 |             0 | base/25171/27431
--  migration_v1_lab | orders_no_pk                            | r       |        27382 |       27382 |             0 | base/25171/27382
--  migration_v1_lab | orders_no_pk_pkey                       | i       |        27462 |       27462 |             0 | base/25171/27462
--  migration_v1_lab | orphan_seq                              | S       |        27391 |       27391 |             0 | base/25171/27391
--  migration_v1_lab | parent_accounts                         | r       |        27392 |       27392 |             0 | base/25171/27392
--  migration_v1_lab | parent_accounts_pkey                    | i       |        27399 |       27399 |             0 | base/25171/27399
--  migration_v1_lab | product_catalog                         | r       |        27418 |       27418 |             0 | base/25171/27418
--  migration_v1_lab | product_catalog_pkey                    | i       |        27429 |       27429 |             0 | base/25171/27429
--  migration_v1_lab | product_catalog_product_id_seq          | S       |        27417 |       27417 |             0 | base/25171/27417
--  migration_v1_lab | sales_orders                            | r       |        27434 |       27434 |             0 | base/25171/27434
--  migration_v1_lab | sales_orders_sales_order_id_seq         | S       |        27433 |       27433 |             0 | base/25171/27433
--  migration_v1_lab | stale_stats_table                       | r       |        27443 |       27443 |             0 | base/25171/27443
--  migration_v1_lab | stale_stats_table_id_seq                | S       |        27442 |       27442 |             0 | base/25171/27442
--  migration_v1_lab | stale_stats_table_pkey                  | i       |        27450 |       27450 |             0 | base/25171/27450
--  migration_v2_lab | QuotedOrders_pkey                       | i       |        27557 |       27557 |             0 | base/25171/27557
--  migration_v2_lab | amount_mapping_risk                     | r       |        27593 |       27593 |             0 | base/25171/27593
--  migration_v2_lab | amount_mapping_risk_id_seq              | S       |        27592 |       27592 |             0 | base/25171/27592
--  migration_v2_lab | amount_mapping_risk_pkey                | i       |        27600 |       27600 |             0 | base/25171/27600
--  migration_v2_lab | bloat_pressure_table                    | r       |        27572 |       27572 |             0 | base/25171/27572
--  migration_v2_lab | bloat_pressure_table_id_seq             | S       |        27571 |       27571 |             0 | base/25171/27571
--  migration_v2_lab | bloat_pressure_table_pkey               | i       |        27581 |       27581 |             0 | base/25171/27581
--  migration_v2_lab | child_events                            | r       |        27514 |       27514 |             0 | base/25171/27514
--  migration_v2_lab | child_events_event_id_seq               | S       |        27513 |       27513 |             0 | base/25171/27513
--  migration_v2_lab | child_events_pkey                       | i       |        27525 |       27525 |             0 | base/25171/27525
--  migration_v2_lab | customer_contact_compat                 | r       |        27584 |       27584 |             0 | base/25171/27584
--  migration_v2_lab | customer_contact_compat_customer_id_seq | S       |        27583 |       27583 |             0 | base/25171/27583
--  migration_v2_lab | customer_contact_compat_pkey            | i       |        27590 |       27590 |             0 | base/25171/27590
-- ... remaining sample rows omitted; run the script for current environment-specific results.
-- SAMPLE_OUTPUT_END
