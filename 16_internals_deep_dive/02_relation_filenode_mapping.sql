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
--  migration_v2_lab | customer_staging_no_pk                  | r       |        27491 |       27491 |             0 | base/25171/27491
--  migration_v2_lab | customer_staging_no_pk_pkey             | i       |        27688 |       27688 |             0 | base/25171/27688
--  migration_v2_lab | idx_v2_child_events_account_id          | i       |        27691 |       27691 |             0 | base/25171/27691
--  migration_v2_lab | idx_v2_order_fact_filter_key            | i       |        27693 |       27693 |             0 | base/25171/27693
--  migration_v2_lab | idx_v2_order_fact_search_lower          | i       |        27694 |       27694 |             0 | base/25171/27694
--  migration_v2_lab | idx_v2_sales_ref_a                      | i       |        27546 |       27546 |             0 | base/25171/27546
--  migration_v2_lab | issue_manifest                          | r       |        27479 |       27479 |             0 | base/25171/27479
--  migration_v2_lab | issue_manifest_pkey                     | i       |        27489 |       27489 |             0 | base/25171/27489
--  migration_v2_lab | mv_daily_order_volume                   | m       |        27645 |       27695 |             0 | base/25171/27695
--  migration_v2_lab | order_fact                              | r       |        27603 |       27603 |             0 | base/25171/27603
--  migration_v2_lab | order_fact_order_id_seq                 | S       |        27602 |       27602 |             0 | base/25171/27602
--  migration_v2_lab | order_fact_pkey                         | i       |        27615 |       27615 |             0 | base/25171/27615
--  migration_v2_lab | orphan_order_seq                        | S       |        27501 |       27501 |             0 | base/25171/27501
--  migration_v2_lab | parent_accounts                         | r       |        27502 |       27502 |             0 | base/25171/27502
--  migration_v2_lab | parent_accounts_pkey                    | i       |        27511 |       27511 |             0 | base/25171/27511
--  migration_v2_lab | partitioned_events                      | p       |        27657 |             |             0 | 
--  migration_v2_lab | partitioned_events_2025                 | r       |        27665 |       27665 |             0 | base/25171/27665
--  migration_v2_lab | partitioned_events_2025_pkey            | i       |        27668 |       27668 |             0 | base/25171/27668
--  migration_v2_lab | partitioned_events_2026                 | r       |        27675 |       27675 |             0 | base/25171/27675
--  migration_v2_lab | partitioned_events_2026_pkey            | i       |        27678 |       27678 |             0 | base/25171/27678
--  migration_v2_lab | partitioned_events_event_id_seq         | S       |        27656 |       27656 |             0 | base/25171/27656
--  migration_v2_lab | partitioned_events_pkey                 | I       |        27663 |             |             0 | 
--  migration_v2_lab | quoted_orders                           | r       |        27549 |       27549 |             0 | base/25171/27549
--  migration_v2_lab | quoted_orders_quoted_order_id_seq       | S       |        27548 |       27548 |             0 | base/25171/27548
--  migration_v2_lab | sales_catalog                           | r       |        27533 |       27533 |             0 | base/25171/27533
--  migration_v2_lab | sales_catalog_catalog_id_seq            | S       |        27532 |       27532 |             0 | base/25171/27532
--  migration_v2_lab | sales_catalog_pkey                      | i       |        27544 |       27544 |             0 | base/25171/27544
--  migration_v2_lab | stale_stats_table                       | r       |        27560 |       27560 |             0 | base/25171/27560
--  migration_v2_lab | stale_stats_table_id_seq                | S       |        27559 |       27559 |             0 | base/25171/27559
--  migration_v2_lab | stale_stats_table_pkey                  | i       |        27569 |       27569 |             0 | base/25171/27569
--  migration_v2_lab | trigger_audit_demo                      | r       |        27626 |       27626 |             0 | base/25171/27626
--  migration_v2_lab | trigger_audit_demo_id_seq               | S       |        27625 |       27625 |             0 | base/25171/27625
--  migration_v2_lab | trigger_audit_demo_pkey                 | i       |        27635 |       27635 |             0 | base/25171/27635
--  migration_v2_lab | vw_high_value_orders                    | v       |        27641 |             |             0 | 
--  public           | pg_stat_statements                      | v       |        25236 |             |             0 | 
--  public           | pg_stat_statements_info                 | v       |        25212 |             |             0 | 
--  public           | pgbench_accounts                        | r       |        25179 |       25187 |             0 | base/25171/25187
--  public           | pgbench_accounts_pkey                   | i       |        25195 |       25195 |             0 | base/25171/25195
--  public           | pgbench_branches                        | r       |        25183 |       25188 |             0 | base/25171/25188
--  public           | pgbench_branches_pkey                   | i       |        25191 |       25191 |             0 | base/25171/25191
--  public           | pgbench_history                         | r       |        25172 |       25251 |             0 | base/25171/25251
--  public           | pgbench_tellers                         | r       |        25175 |       25190 |             0 | base/25171/25190
--  public           | pgbench_tellers_pkey                    | i       |        25193 |       25193 |             0 | base/25171/25193
-- (83 rows)
-- 
-- SAMPLE_OUTPUT_END
