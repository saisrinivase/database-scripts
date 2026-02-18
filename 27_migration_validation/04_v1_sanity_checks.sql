/*
Purpose: Sanity assertions for V1 migration validation workflow.
Area: Migration Validation
Usage:
  psql "host=<host> port=<port> dbname=<db> user=<user>" \
    -f 27_migration_validation/04_v1_sanity_checks.sql

Notes:
  - Targets migration_v1_lab objects only.
  - PASS/FAIL summary can be archived with release artifacts.
*/

\set ON_ERROR_STOP on
\pset pager off

DROP TABLE IF EXISTS tmp_v1_sanity_results;

CREATE TEMP TABLE tmp_v1_sanity_results (
    check_name text NOT NULL,
    status text NOT NULL,
    observed_value text NOT NULL,
    expected_value text NOT NULL,
    recommendation text NOT NULL
);

INSERT INTO tmp_v1_sanity_results
SELECT
    'PK_PRESENT_orders_no_pk' AS check_name,
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_constraint c
        JOIN pg_class t
            ON t.oid = c.conrelid
        JOIN pg_namespace n
            ON n.oid = t.relnamespace
        WHERE n.nspname = 'migration_v1_lab'
          AND t.relname = 'orders_no_pk'
          AND c.contype = 'p'
    ) THEN 'PASS' ELSE 'FAIL' END AS status,
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_constraint c
        JOIN pg_class t
            ON t.oid = c.conrelid
        JOIN pg_namespace n
            ON n.oid = t.relnamespace
        WHERE n.nspname = 'migration_v1_lab'
          AND t.relname = 'orders_no_pk'
          AND c.contype = 'p'
    ) THEN 'present' ELSE 'missing' END AS observed_value,
    'present' AS expected_value,
    'Add primary key on migration_v1_lab.orders_no_pk(order_id).'

UNION ALL

SELECT
    'FK_INDEX_PRESENT_child_transactions',
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n
            ON n.oid = c.relnamespace
        JOIN pg_index i
            ON i.indrelid = c.oid
        JOIN pg_attribute a
            ON a.attrelid = c.oid
           AND a.attnum = ANY (i.indkey)
        WHERE n.nspname = 'migration_v1_lab'
          AND c.relname = 'child_transactions'
          AND a.attname = 'account_id'
          AND i.indisvalid
          AND i.indisready
    ) THEN 'PASS' ELSE 'FAIL' END,
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n
            ON n.oid = c.relnamespace
        JOIN pg_index i
            ON i.indrelid = c.oid
        JOIN pg_attribute a
            ON a.attrelid = c.oid
           AND a.attnum = ANY (i.indkey)
        WHERE n.nspname = 'migration_v1_lab'
          AND c.relname = 'child_transactions'
          AND a.attname = 'account_id'
          AND i.indisvalid
          AND i.indisready
    ) THEN 'present' ELSE 'missing' END,
    'present',
    'Create index on migration_v1_lab.child_transactions(account_id).'

UNION ALL

SELECT
    'NO_DUPLICATE_SKU_INDEX',
    CASE WHEN (
        SELECT count(*)
        FROM pg_class c
        JOIN pg_namespace n
            ON n.oid = c.relnamespace
        JOIN pg_index i
            ON i.indrelid = c.oid
        JOIN pg_class ci
            ON ci.oid = i.indexrelid
        WHERE n.nspname = 'migration_v1_lab'
          AND c.relname = 'product_catalog'
          AND ci.relname IN ('idx_product_sku_a', 'idx_product_sku_b')
    ) = 1 THEN 'PASS' ELSE 'FAIL' END,
    (
        SELECT count(*)::text
        FROM pg_class c
        JOIN pg_namespace n
            ON n.oid = c.relnamespace
        JOIN pg_index i
            ON i.indrelid = c.oid
        JOIN pg_class ci
            ON ci.oid = i.indexrelid
        WHERE n.nspname = 'migration_v1_lab'
          AND c.relname = 'product_catalog'
          AND ci.relname IN ('idx_product_sku_a', 'idx_product_sku_b')
    ),
    '1',
    'Drop one duplicate index on migration_v1_lab.product_catalog(sku).'

UNION ALL

SELECT
    'NO_UPPERCASE_OBJECTS_IN_LAB',
    CASE WHEN (
        SELECT count(*)
        FROM pg_class c
        JOIN pg_namespace n
            ON n.oid = c.relnamespace
        WHERE n.nspname = 'migration_v1_lab'
          AND c.relkind IN ('r', 'p', 'v', 'm', 'S', 'f')
          AND c.relname ~ '[A-Z]'
    ) = 0 THEN 'PASS' ELSE 'FAIL' END,
    (
        SELECT count(*)::text
        FROM pg_class c
        JOIN pg_namespace n
            ON n.oid = c.relnamespace
        WHERE n.nspname = 'migration_v1_lab'
          AND c.relkind IN ('r', 'p', 'v', 'm', 'S', 'f')
          AND c.relname ~ '[A-Z]'
    ),
    '0',
    'Rename objects to lowercase unless quoted identifiers are intentionally required.'

UNION ALL

SELECT
    'SEQUENCE_OWNED_BY_COLUMN',
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n
            ON n.oid = c.relnamespace
        JOIN pg_depend d
            ON d.objid = c.oid
           AND d.deptype = 'a'
           AND d.refclassid = 'pg_class'::regclass
        WHERE n.nspname = 'migration_v1_lab'
          AND c.relkind = 'S'
          AND c.relname = 'orphan_seq'
    ) THEN 'PASS' ELSE 'FAIL' END,
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n
            ON n.oid = c.relnamespace
        JOIN pg_depend d
            ON d.objid = c.oid
           AND d.deptype = 'a'
           AND d.refclassid = 'pg_class'::regclass
        WHERE n.nspname = 'migration_v1_lab'
          AND c.relkind = 'S'
          AND c.relname = 'orphan_seq'
    ) THEN 'owned' ELSE 'unowned' END,
    'owned',
    'Run ALTER SEQUENCE ... OWNED BY ... to bind sequence lifecycle.'

UNION ALL

SELECT
    'STALE_STATS_TABLE_HEALTH',
    CASE WHEN (
        SELECT
            count(*)
        FROM pg_stat_user_tables s
        WHERE s.schemaname = 'migration_v1_lab'
          AND s.relname = 'stale_stats_table'
          AND s.n_mod_since_analyze > 50000
          AND (
              GREATEST(s.last_analyze, s.last_autoanalyze) IS NULL
              OR now() - GREATEST(s.last_analyze, s.last_autoanalyze) > interval '1 day'
          )
    ) = 0 THEN 'PASS' ELSE 'FAIL' END,
    (
        SELECT
            count(*)::text
        FROM pg_stat_user_tables s
        WHERE s.schemaname = 'migration_v1_lab'
          AND s.relname = 'stale_stats_table'
          AND s.n_mod_since_analyze > 50000
          AND (
              GREATEST(s.last_analyze, s.last_autoanalyze) IS NULL
              OR now() - GREATEST(s.last_analyze, s.last_autoanalyze) > interval '1 day'
          )
    ),
    '0',
    'Run ANALYZE and keep autoanalyze enabled.'

UNION ALL

SELECT
    'DEAD_TUPLE_PRESSURE_CLEAR',
    CASE WHEN (
        SELECT
            count(*)
        FROM pg_stat_user_tables s
        WHERE s.schemaname = 'migration_v1_lab'
          AND s.relname = 'dml_bloat_table'
          AND s.n_dead_tup >= 10000
          AND round(100.0 * s.n_dead_tup / NULLIF(s.n_live_tup + s.n_dead_tup, 0), 2) >= 20
    ) = 0 THEN 'PASS' ELSE 'FAIL' END,
    (
        SELECT
            count(*)::text
        FROM pg_stat_user_tables s
        WHERE s.schemaname = 'migration_v1_lab'
          AND s.relname = 'dml_bloat_table'
          AND s.n_dead_tup >= 10000
          AND round(100.0 * s.n_dead_tup / NULLIF(s.n_live_tup + s.n_dead_tup, 0), 2) >= 20
    ),
    '0',
    'Run VACUUM (ANALYZE) and keep autovacuum enabled.'
;

\pset title 'V1 Sanity Check Results'
SELECT
    check_name,
    status,
    observed_value,
    expected_value,
    recommendation
FROM tmp_v1_sanity_results
ORDER BY check_name;

\pset title 'V1 Sanity Summary'
SELECT
    count(*) AS total_checks,
    count(*) FILTER (WHERE status = 'PASS') AS passed_checks,
    count(*) FILTER (WHERE status = 'FAIL') AS failed_checks,
    CASE
        WHEN count(*) FILTER (WHERE status = 'FAIL') = 0 THEN 'YES'
        ELSE 'NO'
    END AS all_passed
FROM tmp_v1_sanity_results;
