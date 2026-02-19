/*
Purpose: Resolve seeded V1 migration issues created by 02_seed_v1_test_issues.sql.
Area: Migration Validation
Usage:
  psql "host=<host> port=<port> dbname=<db> user=<user>" \
    -f 27_migration_validation/03_fix_v1_test_issues.sql
*/

\set ON_ERROR_STOP on
\pset pager off

\echo [V1 fix] Adding primary key to orders_no_pk...
ALTER TABLE migration_v1_lab.orders_no_pk
    ADD CONSTRAINT orders_no_pk_pkey PRIMARY KEY (order_id);

\echo [V1 fix] Attaching orphan sequence ownership...
ALTER SEQUENCE migration_v1_lab.orphan_seq
    OWNED BY migration_v1_lab.orders_no_pk.order_id;

\echo [V1 fix] Adding FK supporting index...
CREATE INDEX idx_child_transactions_account_id
    ON migration_v1_lab.child_transactions (account_id);

\echo [V1 fix] Removing duplicate index...
DROP INDEX IF EXISTS migration_v1_lab.idx_product_sku_b;

\echo [V1 fix] Normalizing uppercase table name...
ALTER TABLE migration_v1_lab."SalesOrders"
    RENAME TO sales_orders;

\echo [V1 fix] Normalizing uppercase identity sequence name...
ALTER SEQUENCE IF EXISTS migration_v1_lab."SalesOrders_sales_order_id_seq"
    RENAME TO sales_orders_sales_order_id_seq;

\echo [V1 fix] Re-enabling autovacuum and refreshing stats...
ALTER TABLE migration_v1_lab.stale_stats_table
    RESET (autovacuum_enabled, toast.autovacuum_enabled);
ANALYZE migration_v1_lab.stale_stats_table;

\echo [V1 fix] Cleaning dead tuples from pressure table...
ALTER TABLE migration_v1_lab.dml_bloat_table
    RESET (autovacuum_enabled, toast.autovacuum_enabled);
VACUUM (ANALYZE) migration_v1_lab.dml_bloat_table;

\echo [V1 fix] Fix complete.


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

Pager usage is off.
[V1 fix] Adding primary key to orders_no_pk...
ALTER TABLE
[V1 fix] Attaching orphan sequence ownership...
ALTER SEQUENCE
[V1 fix] Adding FK supporting index...
CREATE INDEX
[V1 fix] Removing duplicate index...
DROP INDEX
[V1 fix] Normalizing uppercase table name...
ALTER TABLE
[V1 fix] Normalizing uppercase identity sequence name...
ALTER SEQUENCE
[V1 fix] Re-enabling autovacuum and refreshing stats...
ALTER TABLE
ANALYZE
[V1 fix] Cleaning dead tuples from pressure table...
ALTER TABLE
VACUUM
[V1 fix] Fix complete.

SAMPLE_OUTPUT_END */
