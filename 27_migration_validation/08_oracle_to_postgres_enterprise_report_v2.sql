/*
Purpose: Generate an enterprise-style HTML report with deep object coverage and issue diagnostics.
Area: Migration Validation
Usage:
  psql "host=<host> port=<port> dbname=<db> user=<user>" \
    -v report_file='postgres_enterprise_migration_report_v2.html' \
    -f 27_migration_validation/08_oracle_to_postgres_enterprise_report_v2.sql

Notes:
  - Designed to evaluate both migration_v2_lab seeded issues and broader environment checks.
  - Covers object inventory and issue checks with clear explanations and recommendations.
*/

\set ON_ERROR_STOP on
\pset pager off
\pset border 1
\pset format html

\if :{?report_file}
\else
\set report_file 'postgres_enterprise_migration_report_v2.html'
\endif

\o :report_file

\qecho <!DOCTYPE html>
\qecho <html>
\qecho <head>
\qecho <meta charset="utf-8">
\qecho <title>PostgreSQL Enterprise Migration & Performance Report V2</title>
\qecho <style>
\qecho body { font-family: "Segoe UI", Arial, sans-serif; margin: 24px; color: #17212b; background: #f6f8fb; }
\qecho h1 { color: #0b3b8f; margin-bottom: 4px; }
\qecho h2 { color: #154a9a; margin-top: 26px; }
\qecho .meta { color: #4b5b71; margin-bottom: 14px; }
\qecho .kpi { display: grid; grid-template-columns: repeat(5, minmax(120px, 1fr)); gap: 10px; margin: 16px 0 20px; }
\qecho .card { background: #ffffff; border: 1px solid #d7e0ef; border-radius: 8px; padding: 10px 12px; }
\qecho .label { font-size: 12px; color: #5c6f89; text-transform: uppercase; letter-spacing: .04em; }
\qecho .value { font-size: 24px; font-weight: 700; color: #0b3b8f; }
\qecho table { border-collapse: collapse; width: 100%; background: #ffffff; margin-bottom: 22px; }
\qecho th { background: #113f8c; color: #ffffff; padding: 8px; border: 1px solid #d7e0ef; text-align: left; }
\qecho td { padding: 7px; border: 1px solid #d7e0ef; vertical-align: top; }
\qecho tr:nth-child(even) td { background: #f8fbff; }
\qecho caption { caption-side: top; text-align: left; font-weight: 700; color: #183f80; margin: 0 0 8px 0; }
\qecho .foot { margin-top: 24px; color: #5c6f89; font-size: 12px; }
\qecho </style>
\qecho </head>
\qecho <body>
\qecho <h1>PostgreSQL Enterprise Migration & Performance Report (V2)</h1>
\qecho <div class="meta">Object-level + issue-level coverage with clear remediation guidance.</div>

\pset title 'Report Metadata'
SELECT
    current_database() AS database_name,
    current_user AS executed_by,
    version() AS postgres_version,
    current_setting('server_version_num') AS server_version_num,
    pg_postmaster_start_time() AS instance_start_time,
    now() AS report_generated_at;

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

CREATE OR REPLACE FUNCTION pg_temp.safe_text(sql_text text, default_text text)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    v text;
BEGIN
    EXECUTE format('SELECT COALESCE((%s)::text, %L)', sql_text, default_text) INTO v;
    RETURN COALESCE(v, default_text);
EXCEPTION WHEN undefined_table OR undefined_column THEN
    RETURN default_text;
END;
$$;

CREATE TEMP TABLE tmp_mv2_checks (
    check_id text NOT NULL,
    issue_title text NOT NULL,
    area text NOT NULL,
    severity text NOT NULL,
    status text NOT NULL,
    issue_count bigint NOT NULL,
    threshold_rule text NOT NULL,
    why_it_matters text NOT NULL,
    evidence text NOT NULL,
    recommended_action text NOT NULL,
    seed_coverage text NOT NULL,
    runbook_ref text NOT NULL
);

INSERT INTO tmp_mv2_checks
SELECT
    'MV2-EXT-001',
    'pg_stat_statements extension availability',
    'Environment',
    'MEDIUM',
    CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN 'PASS' ELSE 'WARN' END,
    CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN 0 ELSE 1 END,
    'pg_stat_statements should be installed for reliable query telemetry',
    'Query-level bottleneck analysis depends on statement stats history.',
    CASE
        WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN 'installed'
        ELSE 'missing'
    END,
    'Install extension and preload library where required.',
    'No (environment-level)',
    '11_performance_tuning/* + 28_pgss_resource_attribution/*'

UNION ALL

SELECT
    'MV2-CFG-001',
    'autovacuum enabled',
    'Configuration',
    'CRITICAL',
    CASE WHEN lower(setting) IN ('on', 'true', '1') THEN 'PASS' ELSE 'FAIL' END,
    CASE WHEN lower(setting) IN ('on', 'true', '1') THEN 0 ELSE 1 END,
    'autovacuum must be enabled',
    'Without autovacuum, dead tuples and xid age can grow into production outages.',
    'autovacuum=' || setting,
    'Enable autovacuum and tune thresholds by table size/write volume.',
    'No (environment-level)',
    '07_vacuum_bloat/* + 21_configuration_parameters/03_autovacuum_settings.sql'
FROM pg_settings
WHERE name = 'autovacuum'

UNION ALL

SELECT
    'MV2-CFG-002',
    'track_io_timing enabled',
    'Configuration',
    'MEDIUM',
    CASE WHEN lower(setting) IN ('on', 'true', '1') THEN 'PASS' ELSE 'WARN' END,
    CASE WHEN lower(setting) IN ('on', 'true', '1') THEN 0 ELSE 1 END,
    'track_io_timing should be enabled for accurate I/O attribution',
    'I/O root-cause analysis is weaker without block timing visibility.',
    'track_io_timing=' || setting,
    'Set track_io_timing=on and reload configuration.',
    'No (environment-level)',
    '13_io_wal_checkpoints/* + 26_physical_cloud_diagnostics/*'
FROM pg_settings
WHERE name = 'track_io_timing'

UNION ALL

SELECT
    'MV2-OBJ-001',
    'Tables without primary key (migration_v2_lab)',
    'Schema Design',
    'CRITICAL',
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'FAIL' END,
    issue_count,
    'All base tables should have PKs',
    'Missing PKs affect integrity, replication safety, and tuning strategy.',
    evidence,
    'Add PK on stable business/surrogate key columns.',
    'Yes',
    '05_seed_v2_test_issues.sql / 06_fix_v2_test_issues.sql'
FROM (
    WITH no_pk AS (
        SELECT format('%I.%I', n.nspname, c.relname) AS table_name
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relkind = 'r'
          AND NOT EXISTS (
              SELECT 1
              FROM pg_constraint con
              WHERE con.conrelid = c.oid
                AND con.contype = 'p'
          )
    )
    SELECT
        count(*)::bigint AS issue_count,
        COALESCE((SELECT string_agg(table_name, ', ') FROM (SELECT table_name FROM no_pk ORDER BY table_name LIMIT 5) s), 'none') AS evidence
    FROM no_pk
) x

UNION ALL

SELECT
    'MV2-OBJ-002',
    'Foreign keys without supporting index (migration_v2_lab)',
    'Referential Integrity',
    'HIGH',
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'FAIL' END,
    issue_count,
    'FK referencing columns should be indexed',
    'Missing FK indexes can severely slow parent UPDATE/DELETE operations.',
    evidence,
    'Create indexes on FK referencing columns.',
    'Yes',
    '05_seed_v2_test_issues.sql / 06_fix_v2_test_issues.sql'
FROM (
    WITH fk AS (
        SELECT
            c.oid AS con_oid,
            c.conrelid,
            c.conkey,
            n.nspname,
            t.relname,
            c.conname
        FROM pg_constraint c
        JOIN pg_class t ON t.oid = c.conrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE c.contype = 'f'
          AND n.nspname = 'migration_v2_lab'
    ),
    missing AS (
        SELECT format('%I.%I(%s)', fk.nspname, fk.relname, fk.conname) AS fk_name
        FROM fk
        WHERE NOT EXISTS (
            SELECT 1
            FROM pg_index i
            WHERE i.indrelid = fk.conrelid
              AND i.indisvalid
              AND i.indisready
              AND (i.indkey::smallint[])[1:array_length(fk.conkey, 1)] = fk.conkey
        )
    )
    SELECT
        count(*)::bigint AS issue_count,
        COALESCE((SELECT string_agg(fk_name, ', ') FROM (SELECT fk_name FROM missing ORDER BY fk_name LIMIT 5) s), 'none') AS evidence
    FROM missing
) x

UNION ALL

SELECT
    'MV2-OBJ-003',
    'Duplicate indexes (migration_v2_lab)',
    'Index Hygiene',
    'MEDIUM',
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'WARN' END,
    issue_count,
    'Avoid duplicate indexes with same definition',
    'Duplicate indexes increase write cost and maintenance overhead.',
    evidence,
    'Drop redundant index after workload validation.',
    'Yes',
    '03_index_analysis/03_duplicate_indexes.sql + 06_fix_v2_test_issues.sql'
FROM (
    WITH idx AS (
        SELECT
            n.nspname,
            c.relname AS table_name,
            ci.relname AS index_name,
            i.indrelid,
            i.indkey,
            i.indclass,
            i.indcollation,
            i.indoption,
            i.indpred,
            i.indexprs
        FROM pg_index i
        JOIN pg_class c ON c.oid = i.indrelid
        JOIN pg_class ci ON ci.oid = i.indexrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'migration_v2_lab'
    ),
    dup AS (
        SELECT
            nspname,
            table_name,
            array_agg(index_name ORDER BY index_name) AS names
        FROM idx
        GROUP BY nspname, table_name, indrelid, indkey, indclass, indcollation, indoption, indpred, indexprs
        HAVING count(*) > 1
    )
    SELECT
        count(*)::bigint AS issue_count,
        COALESCE((SELECT string_agg(format('%I.%I -> %s', nspname, table_name, array_to_string(names, '|')), ', ') FROM (SELECT * FROM dup LIMIT 3) s), 'none') AS evidence
    FROM dup
) x

UNION ALL

SELECT
    'MV2-OBJ-004',
    'Uppercase quoted object names (migration_v2_lab)',
    'Naming Standards',
    'MEDIUM',
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'WARN' END,
    issue_count,
    'Uppercase object names should be avoided unless required',
    'Quoted casing increases SQL fragility in migrated code paths.',
    evidence,
    'Rename objects to lowercase standard names.',
    'Yes',
    '05_seed_v2_test_issues.sql / 06_fix_v2_test_issues.sql'
FROM (
    WITH bad AS (
        SELECT format('%I.%I', n.nspname, c.relname) AS obj
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relkind IN ('r', 'p', 'v', 'm', 'S', 'f')
          AND c.relname ~ '[A-Z]'
    )
    SELECT
        count(*)::bigint AS issue_count,
        COALESCE((SELECT string_agg(obj, ', ') FROM (SELECT obj FROM bad ORDER BY obj LIMIT 5) s), 'none') AS evidence
    FROM bad
) x

UNION ALL

SELECT
    'MV2-OBJ-005',
    'Unowned sequences (migration_v2_lab)',
    'Sequence Lifecycle',
    'HIGH',
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'WARN' END,
    issue_count,
    'Sequences should be owned by target columns',
    'Unowned sequences are easy to orphan during schema evolution.',
    evidence,
    'Run ALTER SEQUENCE ... OWNED BY ... for lifecycle safety.',
    'Yes',
    '05_seed_v2_test_issues.sql / 06_fix_v2_test_issues.sql'
FROM (
    WITH orphan AS (
        SELECT format('%I.%I', n.nspname, c.relname) AS seq_name
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'migration_v2_lab'
          AND c.relkind = 'S'
          AND NOT EXISTS (
              SELECT 1
              FROM pg_depend d
              WHERE d.objid = c.oid
                AND d.deptype = 'a'
                AND d.refclassid = 'pg_class'::regclass
          )
    )
    SELECT
        count(*)::bigint AS issue_count,
        COALESCE((SELECT string_agg(seq_name, ', ') FROM (SELECT seq_name FROM orphan ORDER BY seq_name LIMIT 5) s), 'none') AS evidence
    FROM orphan
) x

UNION ALL

SELECT
    'MV2-STAT-001',
    'Stale table statistics pressure',
    'Planner Statistics',
    'HIGH',
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'WARN' END,
    issue_count,
    'n_mod_since_analyze should not greatly exceed analyze recency policy',
    'Stale stats drive poor plans and unstable latency.',
    evidence,
    'Run ANALYZE and ensure autoanalyze thresholds are tuned.',
    'Yes',
    '12_planner_statistics/01_tables_needing_analyze.sql + 06_fix_v2_test_issues.sql'
FROM (
    SELECT
        count(*)::bigint AS issue_count,
        COALESCE(
            (SELECT string_agg(format('%I.%I mods=%s', schemaname, relname, n_mod_since_analyze), ', ')
             FROM (
                 SELECT schemaname, relname, n_mod_since_analyze
                 FROM pg_stat_user_tables
                 WHERE schemaname = 'migration_v2_lab'
                   AND n_mod_since_analyze > 100000
                   AND (
                       GREATEST(last_analyze, last_autoanalyze) IS NULL
                       OR now() - GREATEST(last_analyze, last_autoanalyze) > interval '1 day'
                   )
                 ORDER BY n_mod_since_analyze DESC
                 LIMIT 5
             ) s),
            'none'
        ) AS evidence
    FROM pg_stat_user_tables
    WHERE schemaname = 'migration_v2_lab'
      AND n_mod_since_analyze > 100000
      AND (
          GREATEST(last_analyze, last_autoanalyze) IS NULL
          OR now() - GREATEST(last_analyze, last_autoanalyze) > interval '1 day'
      )
) x

UNION ALL

SELECT
    'MV2-MAINT-001',
    'Dead tuple / bloat pressure',
    'Maintenance',
    'HIGH',
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'WARN' END,
    issue_count,
    'Dead tuple ratio should stay below risk thresholds',
    'High dead tuples imply storage bloat and worse scan latency.',
    evidence,
    'Tune autovacuum and run VACUUM (ANALYZE) for hotspots.',
    'Yes',
    '07_vacuum_bloat/* + 06_fix_v2_test_issues.sql'
FROM (
    SELECT
        count(*)::bigint AS issue_count,
        COALESCE(
            (SELECT string_agg(format('%I.%I dead=%s', schemaname, relname, n_dead_tup), ', ')
             FROM (
                 SELECT schemaname, relname, n_dead_tup
                 FROM pg_stat_user_tables
                 WHERE schemaname = 'migration_v2_lab'
                   AND n_dead_tup >= 10000
                   AND round(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) >= 20
                 ORDER BY n_dead_tup DESC
                 LIMIT 5
             ) s),
            'none'
        ) AS evidence
    FROM pg_stat_user_tables
    WHERE schemaname = 'migration_v2_lab'
      AND n_dead_tup >= 10000
      AND round(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) >= 20
) x

UNION ALL

SELECT
    'MV2-DATA-001',
    'Oracle empty-string semantic mismatch',
    'Data Quality',
    'HIGH',
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'WARN' END,
    issue_count,
    'Columns expected to treat empty strings as NULL should be normalized',
    'Oracle and PostgreSQL differ on empty-string semantics.',
    'rows_with_empty=' || issue_count,
    'Use NULLIF(col, '''') during migration cleanup or ETL.',
    'Yes',
    '05_seed_v2_test_issues.sql / 06_fix_v2_test_issues.sql'
FROM (
    SELECT pg_temp.safe_count(
        $q$SELECT 1 FROM migration_v2_lab.customer_contact_compat
           WHERE email = '' OR phone = '' OR comments = ''$q$
    ) AS issue_count
) x

UNION ALL

SELECT
    'MV2-DATA-002',
    'Numeric overflow mapping risk (int4 target)',
    'Data Type Mapping',
    'HIGH',
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'WARN' END,
    issue_count,
    'Values outside int4 range need bigint/numeric target mapping',
    'Oracle NUMBER mappings can overflow if narrowed too aggressively.',
    'overflow_candidates=' || issue_count,
    'Use bigint/numeric target columns and explicit cast strategy.',
    'Yes',
    '05_seed_v2_test_issues.sql / 06_fix_v2_test_issues.sql'
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
) x

UNION ALL

SELECT
    'MV2-PERF-001',
    'Missing index on join/filter column',
    'Query Performance',
    'MEDIUM',
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'WARN' END,
    issue_count,
    'High-cardinality filter/join columns should be indexed',
    'Missing index causes avoidable full scans and high latency.',
    evidence,
    'Create index on migration_v2_lab.order_fact(filter_key).',
    'Yes',
    '18_long_queries_full_scans/* + 27_high_speed_tuning/03_missing_index_candidates_from_scan_pressure.sql'
FROM (
    SELECT
        CASE WHEN EXISTS (
            SELECT 1
            FROM pg_indexes
            WHERE schemaname = 'migration_v2_lab'
              AND tablename = 'order_fact'
              AND indexdef ILIKE '%(filter_key)%'
        ) THEN 0 ELSE 1 END::bigint AS issue_count,
        CASE WHEN EXISTS (
            SELECT 1
            FROM pg_indexes
            WHERE schemaname = 'migration_v2_lab'
              AND tablename = 'order_fact'
              AND indexdef ILIKE '%(filter_key)%'
        ) THEN 'index present' ELSE 'index missing for filter_key' END AS evidence
) x

UNION ALL

SELECT
    'MV2-PERF-002',
    'Case-insensitive search index path',
    'Search Performance',
    'MEDIUM',
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'WARN' END,
    issue_count,
    'Search-heavy text paths need an index strategy',
    'ILIKE/LOWER search without index can cause expensive scans.',
    evidence,
    'Create functional index on lower(search_text) (or trigram where needed).',
    'Yes',
    '24_complex_filter_search/* + 06_fix_v2_test_issues.sql'
FROM (
    SELECT
        CASE WHEN EXISTS (
            SELECT 1
            FROM pg_indexes
            WHERE schemaname = 'migration_v2_lab'
              AND tablename = 'order_fact'
              AND indexdef ILIKE '%lower(search_text)%'
        ) THEN 0 ELSE 1 END::bigint AS issue_count,
        CASE WHEN EXISTS (
            SELECT 1
            FROM pg_indexes
            WHERE schemaname = 'migration_v2_lab'
              AND tablename = 'order_fact'
              AND indexdef ILIKE '%lower(search_text)%'
        ) THEN 'index present' ELSE 'functional index missing' END AS evidence
) x;

CREATE TEMP TABLE tmp_mv2_inventory (
    object_family text NOT NULL,
    object_type text NOT NULL,
    object_count bigint,
    status text NOT NULL,
    note text NOT NULL
);

INSERT INTO tmp_mv2_inventory
SELECT 'Core Objects', 'TABLE', count(*)::bigint, CASE WHEN count(*) > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END,
       'Base tables in non-system schemas'
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'r'
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'

UNION ALL

SELECT 'Core Objects', 'VIEW', count(*)::bigint, CASE WHEN count(*) > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END,
       'Logical abstraction layer objects'
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'v'
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'

UNION ALL

SELECT 'Core Objects', 'MVIEW', count(*)::bigint, CASE WHEN count(*) > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END,
       'Materialized view objects'
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'm'
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'

UNION ALL

SELECT 'Storage', 'TABLESPACE', count(*)::bigint, CASE WHEN count(*) > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END,
       'Includes default and custom tablespaces'
FROM pg_tablespace

UNION ALL

SELECT 'Core Objects', 'SEQUENCE', count(*)::bigint, CASE WHEN count(*) > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END,
       'Sequence generators'
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'S'
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'

UNION ALL

SELECT 'Core Objects', 'INDEX', count(*)::bigint, CASE WHEN count(*) > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END,
       'All index objects'
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'i'
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'

UNION ALL

SELECT 'Programmability', 'TRIGGER', count(*)::bigint, CASE WHEN count(*) > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END,
       'User-defined triggers'
FROM pg_trigger t
JOIN pg_class c ON c.oid = t.tgrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE NOT t.tgisinternal
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'

UNION ALL

SELECT 'Security', 'GRANT', count(*)::bigint, CASE WHEN count(*) > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END,
       'Table-level privilege grants'
FROM information_schema.table_privileges
WHERE table_schema !~ '^pg_'
  AND table_schema <> 'information_schema'

UNION ALL

SELECT 'Programmability', 'FUNCTION', count(*)::bigint, CASE WHEN count(*) > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END,
       'User functions (prokind=f)'
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.prokind = 'f'
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'

UNION ALL

SELECT 'Programmability', 'PROCEDURE', count(*)::bigint, CASE WHEN count(*) > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END,
       'User procedures (prokind=p)'
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.prokind = 'p'
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'

UNION ALL

SELECT 'Migration Mapping', 'PACKAGE', 0::bigint, 'N/A',
       'Oracle packages are not a native PostgreSQL object (map to schemas + functions/procedures)'

UNION ALL

SELECT 'Partitioning', 'PARTITIONED_TABLE', count(*)::bigint, CASE WHEN count(*) > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END,
       'Parent partitioned tables (relkind=p)'
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'p'
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'

UNION ALL

SELECT 'Partitioning', 'PARTITION', count(*)::bigint, CASE WHEN count(*) > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END,
       'Child partitions (relispartition=true)'
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relispartition
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'

UNION ALL

SELECT 'Schema Modeling', 'TYPE', count(*)::bigint, CASE WHEN count(*) > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END,
       'User enum/composite/domain types'
FROM pg_type t
JOIN pg_namespace n ON n.oid = t.typnamespace
WHERE n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
  AND t.typtype IN ('e', 'c', 'd')

UNION ALL

SELECT 'Data Movement', 'INSERT_OR_COPY_WORKLOAD_SIGNAL',
       pg_temp.safe_count('SELECT 1 FROM pg_stat_statements WHERE query ~* ''^\\s*(insert|copy)\\s+''')::bigint,
       CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN 'OBSERVED' ELSE 'LIMITED' END,
       'Signal from pg_stat_statements when available'

UNION ALL

SELECT 'Federation', 'FDW_SERVER', count(*)::bigint, CASE WHEN count(*) > 0 THEN 'PRESENT' ELSE 'NOT_PRESENT' END,
       'Foreign data wrapper servers'
FROM pg_foreign_server

UNION ALL

SELECT 'Telemetry', 'QUERY',
       CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN 1 ELSE 0 END::bigint,
       CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN 'PRESENT' ELSE 'LIMITED' END,
       'Query telemetry through pg_stat_statements extension'

UNION ALL

SELECT 'Migration Mapping', 'SYNONYM', 0::bigint, 'N/A',
       'Oracle synonym has no direct PostgreSQL object equivalent (use views/search_path)'

UNION ALL

SELECT 'External Integration', 'KETTLE', NULL::bigint, 'EXTERNAL',
       'Pentaho/Kettle metadata is outside PostgreSQL catalogs; validate via ETL repository/tooling';

SELECT
    count(*) AS total_checks,
    count(*) FILTER (WHERE status = 'PASS') AS pass_checks,
    count(*) FILTER (WHERE status = 'WARN') AS warn_checks,
    count(*) FILTER (WHERE status = 'FAIL') AS fail_checks,
    count(*) FILTER (WHERE status NOT IN ('PASS', 'WARN', 'FAIL')) AS other_checks
FROM tmp_mv2_checks
\gset

SELECT (:warn_checks::int + :fail_checks::int) AS open_checks \gset

WITH risk AS (
    SELECT
        sum(
            CASE
                WHEN status = 'FAIL' THEN
                    CASE severity
                        WHEN 'CRITICAL' THEN 25
                        WHEN 'HIGH' THEN 15
                        WHEN 'MEDIUM' THEN 8
                        WHEN 'LOW' THEN 3
                        ELSE 0
                    END
                WHEN status = 'WARN' THEN
                    CASE severity
                        WHEN 'CRITICAL' THEN 12
                        WHEN 'HIGH' THEN 7
                        WHEN 'MEDIUM' THEN 4
                        WHEN 'LOW' THEN 1
                        ELSE 0
                    END
                ELSE 0
            END
        )::int AS risk_points
    FROM tmp_mv2_checks
)
SELECT greatest(100 - coalesce(risk_points, 0), 0) AS health_score,
       coalesce(risk_points, 0) AS risk_points
FROM risk
\gset

\qecho <h2>Executive Snapshot</h2>
\qecho <div class="kpi">
\qecho <div class="card"><div class="label">Health Score</div><div class="value">:health_score</div></div>
\qecho <div class="card"><div class="label">Risk Points</div><div class="value">:risk_points</div></div>
\qecho <div class="card"><div class="label">Checks</div><div class="value">:total_checks</div></div>
\qecho <div class="card"><div class="label">Pass</div><div class="value">:pass_checks</div></div>
\qecho <div class="card"><div class="label">Open Risks</div><div class="value">:open_checks</div></div>
\qecho </div>

\pset title 'Object Coverage Matrix (Deep Inventory)'
SELECT
    object_family,
    object_type,
    object_count,
    status,
    note
FROM tmp_mv2_inventory
ORDER BY object_family, object_type;

\pset title 'Issue Control Matrix'
SELECT
    check_id,
    issue_title,
    area,
    severity,
    status,
    issue_count,
    threshold_rule,
    seed_coverage
FROM tmp_mv2_checks
ORDER BY
    CASE severity WHEN 'CRITICAL' THEN 1 WHEN 'HIGH' THEN 2 WHEN 'MEDIUM' THEN 3 WHEN 'LOW' THEN 4 ELSE 5 END,
    CASE status WHEN 'FAIL' THEN 1 WHEN 'WARN' THEN 2 WHEN 'PASS' THEN 3 ELSE 4 END,
    issue_count DESC,
    check_id;

\pset title 'Issue Playbook (Clear and Precise Guidance)'
SELECT
    check_id,
    issue_title,
    why_it_matters,
    evidence,
    recommended_action,
    runbook_ref
FROM tmp_mv2_checks
ORDER BY
    CASE status WHEN 'FAIL' THEN 1 WHEN 'WARN' THEN 2 WHEN 'PASS' THEN 3 ELSE 4 END,
    CASE severity WHEN 'CRITICAL' THEN 1 WHEN 'HIGH' THEN 2 WHEN 'MEDIUM' THEN 3 WHEN 'LOW' THEN 4 ELSE 5 END,
    check_id;

\pset title 'Open Risks (WARN/FAIL Only)'
SELECT
    check_id,
    issue_title,
    severity,
    status,
    issue_count,
    evidence,
    recommended_action
FROM tmp_mv2_checks
WHERE status IN ('WARN', 'FAIL')
ORDER BY
    CASE status WHEN 'FAIL' THEN 1 ELSE 2 END,
    CASE severity WHEN 'CRITICAL' THEN 1 WHEN 'HIGH' THEN 2 WHEN 'MEDIUM' THEN 3 WHEN 'LOW' THEN 4 ELSE 5 END,
    issue_count DESC,
    check_id;

\qecho <div class="foot">Report generated by 08_oracle_to_postgres_enterprise_report_v2.sql. For deterministic lab testing, run 05_seed_v2_test_issues.sql then re-run this report.</div>
\qecho </body>
\qecho </html>

\o
\pset format aligned
\pset border 1
\pset pager on




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
-- Pager usage is off.
-- Border style is 1.
-- Output format is html.
-- Title is "Report Metadata".
-- Title is "Object Coverage Matrix (Deep Inventory)".
-- Title is "Issue Control Matrix".
-- Title is "Issue Playbook (Clear and Precise Guidance)".
-- Title is "Open Risks (WARN/FAIL Only)".
-- Output format is aligned.
-- Border style is 1.
-- Pager is used for long output.
-- SAMPLE_OUTPUT_END
