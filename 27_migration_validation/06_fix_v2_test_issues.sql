/*
Purpose: Resolve V2 seeded migration/performance issues in migration_v2_lab.
Area: Migration Validation
Usage:
  psql "host=<host> port=<port> dbname=<db> user=<user>" \
    -f 27_migration_validation/06_fix_v2_test_issues.sql
*/

\set ON_ERROR_STOP on
\pset pager off

\echo [V2 fix] Adding primary key to customer_staging_no_pk...
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relname = 'customer_staging_no_pk'
    ) AND NOT EXISTS (
        SELECT 1
        FROM pg_constraint con
        JOIN pg_class c ON c.oid = con.conrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relname = 'customer_staging_no_pk'
          AND con.contype = 'p'
    ) THEN
        ALTER TABLE migration_v2_lab.customer_staging_no_pk
            ADD CONSTRAINT customer_staging_no_pk_pkey PRIMARY KEY (staging_id);
    END IF;
END;
$$;

\echo [V2 fix] Owning sequence by table column...
ALTER TABLE IF EXISTS migration_v2_lab.customer_staging_no_pk
    ALTER COLUMN staging_id SET DEFAULT nextval('migration_v2_lab.orphan_order_seq');
ALTER SEQUENCE IF EXISTS migration_v2_lab.orphan_order_seq
    OWNED BY migration_v2_lab.customer_staging_no_pk.staging_id;

\echo [V2 fix] Creating FK supporting index...
CREATE INDEX IF NOT EXISTS idx_v2_child_events_account_id
    ON migration_v2_lab.child_events (account_id);

\echo [V2 fix] Removing duplicate index...
DROP INDEX IF EXISTS migration_v2_lab.idx_v2_sales_ref_b;

\echo [V2 fix] Normalizing uppercase object names...
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relname = 'QuotedOrders'
    ) AND NOT EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relname = 'quoted_orders'
    ) THEN
        ALTER TABLE migration_v2_lab."QuotedOrders" RENAME TO quoted_orders;
    END IF;
END;
$$;

ALTER SEQUENCE IF EXISTS migration_v2_lab."QuotedOrders_quoted_order_id_seq"
    RENAME TO quoted_orders_quoted_order_id_seq;

\echo [V2 fix] Refreshing stale statistics path...
ALTER TABLE IF EXISTS migration_v2_lab.stale_stats_table
    RESET (autovacuum_enabled, toast.autovacuum_enabled);
ANALYZE migration_v2_lab.stale_stats_table;

\echo [V2 fix] Clearing dead tuple pressure...
ALTER TABLE IF EXISTS migration_v2_lab.bloat_pressure_table
    RESET (autovacuum_enabled, toast.autovacuum_enabled);
VACUUM (ANALYZE) migration_v2_lab.bloat_pressure_table;

\echo [V2 fix] Normalizing Oracle empty-string semantics...
UPDATE migration_v2_lab.customer_contact_compat
SET
    email = NULLIF(email, ''),
    phone = NULLIF(phone, ''),
    comments = NULLIF(comments, '')
WHERE email = '' OR phone = '' OR comments = '';

\echo [V2 fix] Resolving numeric mapping risk...
ALTER TABLE migration_v2_lab.amount_mapping_risk
    ADD COLUMN IF NOT EXISTS target_bigint_model bigint;

UPDATE migration_v2_lab.amount_mapping_risk
SET
    target_int4_model = CASE
        WHEN abs(source_numeric) <= 2147483647 THEN source_numeric::int
        ELSE target_int4_model
    END,
    target_bigint_model = source_numeric::bigint
WHERE target_bigint_model IS NULL
  AND abs(source_numeric) <= 9223372036854775807;

\echo [V2 fix] Adding practical performance indexes...
CREATE INDEX IF NOT EXISTS idx_v2_order_fact_filter_key
    ON migration_v2_lab.order_fact (filter_key);

CREATE INDEX IF NOT EXISTS idx_v2_order_fact_search_lower
    ON migration_v2_lab.order_fact (lower(search_text));

\echo [V2 fix] Refreshing mview and baseline stats...
REFRESH MATERIALIZED VIEW migration_v2_lab.mv_daily_order_volume;

ANALYZE migration_v2_lab.customer_staging_no_pk;
ANALYZE migration_v2_lab.parent_accounts;
ANALYZE migration_v2_lab.child_events;
ANALYZE migration_v2_lab.sales_catalog;
ANALYZE migration_v2_lab.customer_contact_compat;
ANALYZE migration_v2_lab.amount_mapping_risk;
ANALYZE migration_v2_lab.order_fact;
ANALYZE migration_v2_lab.partitioned_events;
ANALYZE migration_v2_lab.quoted_orders;

\echo [V2 fix] Fix complete.
