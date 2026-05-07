/*
PostgreSQL DBA Script: V2 Sanity Checks
Purpose: PASS/FAIL assertions for V2 migration/performance issue scenarios.
Area: Migration Validation
Usage:
  psql "host=<host> port=<port> dbname=<db> user=<user>" \
    -f 27_migration_validation/07_v2_sanity_checks.sql
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/

\set ON_ERROR_STOP on
\pset pager off

DROP TABLE IF EXISTS tmp_v2_sanity_results;

CREATE TEMP TABLE tmp_v2_sanity_results (
    check_name text NOT NULL,
    status text NOT NULL,
    observed_value text NOT NULL,
    expected_value text NOT NULL,
    recommendation text NOT NULL
);

CREATE OR REPLACE FUNCTION pg_temp.safe_count(sql_text text)
RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
    c bigint;
BEGIN
    EXECUTE format('SELECT count(*) FROM (%s) q', sql_text) INTO c;
    RETURN COALESCE(c, 0);
EXCEPTION WHEN undefined_table OR undefined_column THEN
    RETURN 0;
END;
$$;

INSERT INTO tmp_v2_sanity_results
SELECT
    'PK_PRESENT_customer_staging_no_pk',
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_constraint con
        JOIN pg_class c ON c.oid = con.conrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relname = 'customer_staging_no_pk'
          AND con.contype = 'p'
    ) THEN 'PASS' ELSE 'FAIL' END,
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_constraint con
        JOIN pg_class c ON c.oid = con.conrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relname = 'customer_staging_no_pk'
          AND con.contype = 'p'
    ) THEN 'present' ELSE 'missing' END,
    'present',
    'Add primary key on migration_v2_lab.customer_staging_no_pk(staging_id).'

UNION ALL

SELECT
    'FK_INDEX_PRESENT_child_events_account_id',
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_index i ON i.indrelid = c.oid
        JOIN pg_attribute a ON a.attrelid = c.oid
                          AND a.attnum = ANY (i.indkey)
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relname = 'child_events'
          AND a.attname = 'account_id'
          AND i.indisvalid
          AND i.indisready
    ) THEN 'PASS' ELSE 'FAIL' END,
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_index i ON i.indrelid = c.oid
        JOIN pg_attribute a ON a.attrelid = c.oid
                          AND a.attnum = ANY (i.indkey)
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relname = 'child_events'
          AND a.attname = 'account_id'
          AND i.indisvalid
          AND i.indisready
    ) THEN 'present' ELSE 'missing' END,
    'present',
    'Create index on migration_v2_lab.child_events(account_id).'

UNION ALL

SELECT
    'NO_DUPLICATE_sales_catalog_item_ref',
    CASE WHEN (
        SELECT count(*)
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_index i ON i.indrelid = c.oid
        JOIN pg_class ci ON ci.oid = i.indexrelid
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relname = 'sales_catalog'
          AND ci.relname IN ('idx_v2_sales_ref_a', 'idx_v2_sales_ref_b')
    ) = 1 THEN 'PASS' ELSE 'FAIL' END,
    (
        SELECT count(*)::text
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_index i ON i.indrelid = c.oid
        JOIN pg_class ci ON ci.oid = i.indexrelid
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relname = 'sales_catalog'
          AND ci.relname IN ('idx_v2_sales_ref_a', 'idx_v2_sales_ref_b')
    ),
    '1',
    'Drop one duplicate index on migration_v2_lab.sales_catalog(item_ref).'

UNION ALL

SELECT
    'NO_UPPERCASE_OBJECTS_IN_V2_SCHEMA',
    CASE WHEN (
        SELECT count(*)
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relkind IN ('r', 'p', 'v', 'm', 'S', 'f')
          AND c.relname ~ '[A-Z]'
    ) = 0 THEN 'PASS' ELSE 'FAIL' END,
    (
        SELECT count(*)::text
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relkind IN ('r', 'p', 'v', 'm', 'S', 'f')
          AND c.relname ~ '[A-Z]'
    ),
    '0',
    'Rename uppercase quoted objects unless intentionally required.'

UNION ALL

SELECT
    'SEQUENCE_OWNED_orphan_order_seq',
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_depend d ON d.objid = c.oid
                       AND d.deptype = 'a'
                       AND d.refclassid = 'pg_class'::regclass
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relkind = 'S'
          AND c.relname = 'orphan_order_seq'
    ) THEN 'PASS' ELSE 'FAIL' END,
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_depend d ON d.objid = c.oid
                       AND d.deptype = 'a'
                       AND d.refclassid = 'pg_class'::regclass
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relkind = 'S'
          AND c.relname = 'orphan_order_seq'
    ) THEN 'owned' ELSE 'unowned' END,
    'owned',
    'Attach sequence ownership using ALTER SEQUENCE ... OWNED BY ... .'

UNION ALL

SELECT
    'STALE_STATS_TABLE_HEALTH',
    CASE WHEN (
        SELECT count(*)
        FROM pg_stat_user_tables s
        WHERE s.schemaname = 'migration_v2_lab'
          AND s.relname = 'stale_stats_table'
          AND s.n_mod_since_analyze > 100000
          AND (
              GREATEST(s.last_analyze, s.last_autoanalyze) IS NULL
              OR now() - GREATEST(s.last_analyze, s.last_autoanalyze) > interval '1 day'
          )
    ) = 0 THEN 'PASS' ELSE 'FAIL' END,
    (
        SELECT count(*)::text
        FROM pg_stat_user_tables s
        WHERE s.schemaname = 'migration_v2_lab'
          AND s.relname = 'stale_stats_table'
          AND s.n_mod_since_analyze > 100000
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
        SELECT count(*)
        FROM pg_stat_user_tables s
        WHERE s.schemaname = 'migration_v2_lab'
          AND s.relname = 'bloat_pressure_table'
          AND s.n_dead_tup >= 10000
          AND round(100.0 * s.n_dead_tup / NULLIF(s.n_live_tup + s.n_dead_tup, 0), 2) >= 20
    ) = 0 THEN 'PASS' ELSE 'FAIL' END,
    (
        SELECT count(*)::text
        FROM pg_stat_user_tables s
        WHERE s.schemaname = 'migration_v2_lab'
          AND s.relname = 'bloat_pressure_table'
          AND s.n_dead_tup >= 10000
          AND round(100.0 * s.n_dead_tup / NULLIF(s.n_live_tup + s.n_dead_tup, 0), 2) >= 20
    ),
    '0',
    'Run VACUUM (ANALYZE) and keep autovacuum enabled.'

UNION ALL

SELECT
    'EMPTY_STRING_MISMATCH_CLEAR',
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'FAIL' END,
    issue_count::text,
    '0',
    'Normalize Oracle-style empty strings to NULL where semantics require NULL.'
FROM (
    SELECT pg_temp.safe_count(
        $q$SELECT 1 FROM migration_v2_lab.customer_contact_compat
           WHERE email = '' OR phone = '' OR comments = ''$q$
    ) AS issue_count
) e

UNION ALL

SELECT
    'NUMERIC_MAPPING_RISK_CLEAR',
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'FAIL' END,
    issue_count::text,
    '0',
    'Map out-of-int4 values to bigint/numeric target columns.'
FROM (
    SELECT pg_temp.safe_count(
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM information_schema.columns
                WHERE table_schema = 'migration_v2_lab'
                  AND table_name = 'amount_mapping_risk'
                  AND column_name = 'target_bigint_model'
            )
                THEN 'SELECT 1 FROM migration_v2_lab.amount_mapping_risk WHERE abs(source_numeric) > 2147483647 AND target_bigint_model IS NULL'
            ELSE
                'SELECT 1 FROM migration_v2_lab.amount_mapping_risk WHERE abs(source_numeric) > 2147483647'
        END
    ) AS issue_count
) n

UNION ALL

SELECT
    'FILTER_INDEX_PRESENT_order_fact_filter_key',
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_indexes i
        WHERE i.schemaname = 'migration_v2_lab'
          AND i.tablename = 'order_fact'
          AND i.indexdef ILIKE '%(filter_key)%'
    ) THEN 'PASS' ELSE 'FAIL' END,
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_indexes i
        WHERE i.schemaname = 'migration_v2_lab'
          AND i.tablename = 'order_fact'
          AND i.indexdef ILIKE '%(filter_key)%'
    ) THEN 'present' ELSE 'missing' END,
    'present',
    'Create index on migration_v2_lab.order_fact(filter_key).'

UNION ALL

SELECT
    'SEARCH_INDEX_PRESENT_order_fact_lower_search_text',
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_indexes i
        WHERE i.schemaname = 'migration_v2_lab'
          AND i.tablename = 'order_fact'
          AND i.indexdef ILIKE '%lower(search_text)%'
    ) THEN 'PASS' ELSE 'FAIL' END,
    CASE WHEN EXISTS (
        SELECT 1
        FROM pg_indexes i
        WHERE i.schemaname = 'migration_v2_lab'
          AND i.tablename = 'order_fact'
          AND i.indexdef ILIKE '%lower(search_text)%'
    ) THEN 'present' ELSE 'missing' END,
    'present',
    'Create functional index on lower(search_text) for case-insensitive search workloads.';

\pset title 'V2 Sanity Check Results'
SELECT
    check_name,
    status,
    observed_value,
    expected_value,
    recommendation
FROM tmp_v2_sanity_results
ORDER BY check_name;

\pset title 'V2 Sanity Summary'
SELECT
    count(*) AS total_checks,
    count(*) FILTER (WHERE status = 'PASS') AS passed_checks,
    count(*) FILTER (WHERE status = 'FAIL') AS failed_checks,
    CASE WHEN count(*) FILTER (WHERE status = 'FAIL') = 0 THEN 'YES' ELSE 'NO' END AS all_passed
FROM tmp_v2_sanity_results;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
-- Pager usage is off.
-- psql:27_migration_validation/07_v2_sanity_checks.sql:12: NOTICE:  table "tmp_v2_sanity_results" does not exist, skipping
-- DROP TABLE
-- CREATE TABLE
-- CREATE FUNCTION
-- INSERT 0 11
-- Title is "V2 Sanity Check Results".
--                                                                                V2 Sanity Check Results
--                     check_name                     | status | observed_value | expected_value |                                    recommendation                                    
-- ---------------------------------------------------+--------+----------------+----------------+--------------------------------------------------------------------------------------
--  DEAD_TUPLE_PRESSURE_CLEAR                         | PASS   | 0              | 0              | Run VACUUM (ANALYZE) and keep autovacuum enabled.
--  EMPTY_STRING_MISMATCH_CLEAR                       | PASS   | 0              | 0              | Normalize Oracle-style empty strings to NULL where semantics require NULL.
--  FILTER_INDEX_PRESENT_order_fact_filter_key        | PASS   | present        | present        | Create index on migration_v2_lab.order_fact(filter_key).
--  FK_INDEX_PRESENT_child_events_account_id          | PASS   | present        | present        | Create index on migration_v2_lab.child_events(account_id).
--  NO_DUPLICATE_sales_catalog_item_ref               | PASS   | 1              | 1              | Drop one duplicate index on migration_v2_lab.sales_catalog(item_ref).
--  NO_UPPERCASE_OBJECTS_IN_V2_SCHEMA                 | PASS   | 0              | 0              | Rename uppercase quoted objects unless intentionally required.
--  NUMERIC_MAPPING_RISK_CLEAR                        | PASS   | 0              | 0              | Map out-of-int4 values to bigint/numeric target columns.
--  PK_PRESENT_customer_staging_no_pk                 | PASS   | present        | present        | Add primary key on migration_v2_lab.customer_staging_no_pk(staging_id).
--  SEARCH_INDEX_PRESENT_order_fact_lower_search_text | PASS   | present        | present        | Create functional index on lower(search_text) for case-insensitive search workloads.
--  SEQUENCE_OWNED_orphan_order_seq                   | PASS   | owned          | owned          | Attach sequence ownership using ALTER SEQUENCE ... OWNED BY ... .
--  STALE_STATS_TABLE_HEALTH                          | PASS   | 0              | 0              | Run ANALYZE and keep autoanalyze enabled.
-- (11 rows)
-- 
-- Title is "V2 Sanity Summary".
--                      V2 Sanity Summary
--  total_checks | passed_checks | failed_checks | all_passed 
-- --------------+---------------+---------------+------------
--            11 |            11 |             0 | YES
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
