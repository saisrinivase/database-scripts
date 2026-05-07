/*
PostgreSQL DBA Script: Enterprise Takeover Gate V3
Purpose: Enterprise Day-1 takeover gate for Oracle -> PostgreSQL migration.
Area: Migration Validation
Usage:
  psql "host=<host> port=<port> dbname=pgbench_test user=<user>" \
    -v critical_schema_regex='^public$' \
    -v enforce_exit=true \
    -f 27_migration_validation/09_enterprise_takeover_gate_v3.sql

Optional variables:
  - critical_schema_regex: regex for business-critical schemas (default '^public$')
  - enforce_exit: true/false. When true and decision is NO_GO, script exits with code 2.
  - gate_output_file: optional output file path for gate report text.

Decision model:
  - NO_GO: one or more blocker checks in FAIL status.
  - CONDITIONAL_GO: no blocker FAIL, but warnings exist.
  - GO: no blocker FAIL and no warnings.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/

\set ON_ERROR_STOP on
\pset pager off
\pset border 1
\pset footer on

\if :{?critical_schema_regex}
\else
\set critical_schema_regex '^public$'
\endif

\if :{?enforce_exit}
\else
\set enforce_exit true
\endif

\if :{?gate_output_file}
\o :gate_output_file
\endif

\pset title 'Takeover Gate Metadata (V3)'
SELECT
    current_database() AS database_name,
    current_user AS executed_by,
    version() AS postgres_version,
    :'critical_schema_regex' AS critical_schema_regex,
    now() AS evaluated_at;

\set QUIET 1

CREATE TEMP TABLE tmp_takeover_gate_v3 (
    check_id text NOT NULL,
    area text NOT NULL,
    is_blocker boolean NOT NULL,
    status text NOT NULL,
    issue_count bigint NOT NULL,
    threshold_rule text NOT NULL,
    evidence text NOT NULL,
    recommended_action text NOT NULL
);

INSERT INTO tmp_takeover_gate_v3
SELECT
    'TG3-CFG-001',
    'Configuration',
    true,
    CASE WHEN lower(setting) IN ('on', 'true', '1') THEN 'PASS' ELSE 'FAIL' END,
    CASE WHEN lower(setting) IN ('on', 'true', '1') THEN 0 ELSE 1 END,
    'autovacuum must be enabled',
    'autovacuum=' || setting,
    'Enable autovacuum before takeover; validate table-level settings.'
FROM pg_settings
WHERE name = 'autovacuum';

INSERT INTO tmp_takeover_gate_v3
SELECT
    'TG3-ENV-001',
    'Observability',
    false,
    CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN 'PASS' ELSE 'WARN' END,
    CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN 0 ELSE 1 END,
    'pg_stat_statements should be installed for production SQL telemetry',
    CASE
        WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN 'pg_stat_statements=installed'
        ELSE 'pg_stat_statements=missing'
    END,
    'Install pg_stat_statements for Day-1 incident diagnostics and workload tuning.'
;

INSERT INTO tmp_takeover_gate_v3
SELECT
    'TG3-OBJ-001',
    'Objects',
    true,
    CASE WHEN x.issue_count = 0 THEN 'PASS' ELSE 'FAIL' END,
    x.issue_count,
    'No invalid/not-ready indexes allowed',
    CASE
        WHEN x.issue_count = 0 THEN 'none'
        ELSE 'sample=' || x.sample_indexes
    END,
    'Rebuild invalid indexes using REINDEX INDEX CONCURRENTLY where possible.'
FROM (
    WITH bad_idx AS (
        SELECT format('%I.%I', n.nspname, c.relname) AS index_name
        FROM pg_index i
        JOIN pg_class c
            ON c.oid = i.indexrelid
        JOIN pg_namespace n
            ON n.oid = c.relnamespace
        WHERE n.nspname !~ '^pg_'
          AND n.nspname <> 'information_schema'
          AND (NOT i.indisvalid OR NOT i.indisready)
    )
    SELECT
        count(*)::bigint AS issue_count,
        COALESCE(
            (
                SELECT string_agg(index_name, ', ')
                FROM (
                    SELECT index_name
                    FROM bad_idx
                    ORDER BY index_name
                    LIMIT 5
                ) AS s
            ),
            'none'
        ) AS sample_indexes
    FROM bad_idx
) AS x;

INSERT INTO tmp_takeover_gate_v3
SELECT
    'TG3-OBJ-002',
    'Schema Design',
    true,
    CASE WHEN x.issue_count = 0 THEN 'PASS' ELSE 'FAIL' END,
    x.issue_count,
    'Large critical tables should have primary keys',
    CASE
        WHEN x.issue_count = 0 THEN 'none'
        ELSE 'sample=' || x.sample_tables
    END,
    'Add PKs before takeover for integrity and operational safety.'
FROM (
    WITH no_pk AS (
        SELECT format('%I.%I', n.nspname, c.relname) AS table_name
        FROM pg_class c
        JOIN pg_namespace n
            ON n.oid = c.relnamespace
        LEFT JOIN pg_stat_user_tables s
            ON s.relid = c.oid
        WHERE c.relkind = 'r'
          AND n.nspname !~ '^pg_'
          AND n.nspname <> 'information_schema'
          AND n.nspname ~ :'critical_schema_regex'
          AND (
              pg_total_relation_size(c.oid) >= (1::bigint * 1024 * 1024 * 1024)
              OR COALESCE(s.n_live_tup, 0) >= 1000000
          )
          AND NOT EXISTS (
              SELECT 1
              FROM pg_constraint p
              WHERE p.conrelid = c.oid
                AND p.contype = 'p'
          )
    )
    SELECT
        count(*)::bigint AS issue_count,
        COALESCE(
            (
                SELECT string_agg(table_name, ', ')
                FROM (
                    SELECT table_name
                    FROM no_pk
                    ORDER BY table_name
                    LIMIT 5
                ) AS s
            ),
            'none'
        ) AS sample_tables
    FROM no_pk
) AS x;

INSERT INTO tmp_takeover_gate_v3
SELECT
    'TG3-OBJ-003',
    'Referential Integrity',
    true,
    CASE WHEN x.issue_count = 0 THEN 'PASS' ELSE 'FAIL' END,
    x.issue_count,
    'High-volume FK relationships should have supporting indexes',
    CASE
        WHEN x.issue_count = 0 THEN 'none'
        ELSE 'sample=' || x.sample_fk
    END,
    'Create indexes with FK columns as leading columns.'
FROM (
    WITH fk AS (
        SELECT
            c.conrelid,
            c.conname,
            c.conkey,
            n.nspname,
            t.relname,
            COALESCE(s.n_live_tup, 0) AS n_live_tup,
            COALESCE(s.n_mod_since_analyze, 0) AS n_mod_since_analyze
        FROM pg_constraint c
        JOIN pg_class t
            ON t.oid = c.conrelid
        JOIN pg_namespace n
            ON n.oid = t.relnamespace
        LEFT JOIN pg_stat_user_tables s
            ON s.relid = c.conrelid
        WHERE c.contype = 'f'
          AND n.nspname ~ :'critical_schema_regex'
          AND (COALESCE(s.n_live_tup, 0) >= 500000 OR COALESCE(s.n_mod_since_analyze, 0) >= 500000)
    ),
    missing AS (
        SELECT
            format('%I.%I(%I)', fk.nspname, fk.relname, fk.conname) AS fk_name
        FROM fk
        WHERE NOT EXISTS (
            SELECT 1
            FROM pg_index i
            WHERE i.indrelid = fk.conrelid
              AND i.indisvalid
              AND i.indisready
              AND (
                  SELECT array_agg(k.attnum ORDER BY k.ord)
                  FROM unnest(i.indkey::smallint[]) WITH ORDINALITY AS k(attnum, ord)
                  WHERE k.ord <= array_length(fk.conkey, 1)
              ) = fk.conkey
        )
    )
    SELECT
        count(*)::bigint AS issue_count,
        COALESCE(
            (
                SELECT string_agg(fk_name, ', ')
                FROM (
                    SELECT fk_name
                    FROM missing
                    ORDER BY fk_name
                    LIMIT 5
                ) AS s
            ),
            'none'
        ) AS sample_fk
    FROM missing
) AS x;

INSERT INTO tmp_takeover_gate_v3
SELECT
    'TG3-STA-001',
    'Planner Statistics',
    true,
    CASE WHEN x.issue_count = 0 THEN 'PASS' ELSE 'FAIL' END,
    x.issue_count,
    'Large active tables should not have stale stats (mods >= 500k and analyze older than 1 day)',
    CASE
        WHEN x.issue_count = 0 THEN 'none'
        ELSE 'sample=' || x.sample_tables
    END,
    'Run ANALYZE and tune autoanalyze thresholds before takeover.'
FROM (
    WITH stale AS (
        SELECT
            format('%I.%I(mods=%s)', s.schemaname, s.relname, s.n_mod_since_analyze) AS table_name
        FROM pg_stat_user_tables s
        JOIN pg_class c
            ON c.oid = s.relid
        JOIN pg_namespace n
            ON n.oid = c.relnamespace
        WHERE n.nspname ~ :'critical_schema_regex'
          AND pg_total_relation_size(s.relid) >= (1::bigint * 1024 * 1024 * 1024)
          AND s.n_mod_since_analyze >= 500000
          AND (
              GREATEST(s.last_analyze, s.last_autoanalyze) IS NULL
              OR now() - GREATEST(s.last_analyze, s.last_autoanalyze) > interval '1 day'
          )
    )
    SELECT
        count(*)::bigint AS issue_count,
        COALESCE(
            (
                SELECT string_agg(table_name, ', ')
                FROM (
                    SELECT table_name
                    FROM stale
                    ORDER BY table_name
                    LIMIT 5
                ) AS s
            ),
            'none'
        ) AS sample_tables
    FROM stale
) AS x;

INSERT INTO tmp_takeover_gate_v3
SELECT
    'TG3-VAC-001',
    'Vacuum and Bloat',
    true,
    CASE WHEN x.issue_count = 0 THEN 'PASS' ELSE 'FAIL' END,
    x.issue_count,
    'Large critical tables should not exceed dead tuple pressure (>=20% and dead_tup >=500k)',
    CASE
        WHEN x.issue_count = 0 THEN 'none'
        ELSE 'sample=' || x.sample_tables
    END,
    'Run VACUUM (ANALYZE) and tune autovacuum scale factor/threshold.'
FROM (
    WITH pressure AS (
        SELECT
            format(
                '%I.%I(dead_pct=%s)',
                s.schemaname,
                s.relname,
                round(100.0 * s.n_dead_tup / NULLIF(s.n_live_tup + s.n_dead_tup, 0), 2)
            ) AS table_name
        FROM pg_stat_user_tables s
        JOIN pg_class c
            ON c.oid = s.relid
        JOIN pg_namespace n
            ON n.oid = c.relnamespace
        WHERE n.nspname ~ :'critical_schema_regex'
          AND pg_total_relation_size(s.relid) >= (1::bigint * 1024 * 1024 * 1024)
          AND s.n_dead_tup >= 500000
          AND round(100.0 * s.n_dead_tup / NULLIF(s.n_live_tup + s.n_dead_tup, 0), 2) >= 20
    )
    SELECT
        count(*)::bigint AS issue_count,
        COALESCE(
            (
                SELECT string_agg(table_name, ', ')
                FROM (
                    SELECT table_name
                    FROM pressure
                    ORDER BY table_name
                    LIMIT 5
                ) AS s
            ),
            'none'
        ) AS sample_tables
    FROM pressure
) AS x;

INSERT INTO tmp_takeover_gate_v3
SELECT
    'TG3-XID-001',
    'Transaction Safety',
    true,
    CASE WHEN x.issue_count = 0 THEN 'PASS' ELSE 'FAIL' END,
    x.issue_count,
    'No critical schema tables should exceed relfrozenxid age 1.5B',
    CASE
        WHEN x.issue_count = 0 THEN 'none'
        ELSE 'sample=' || x.sample_tables
    END,
    'Run aggressive VACUUM FREEZE cycle before takeover.'
FROM (
    WITH risk AS (
        SELECT
            format('%I.%I(age=%s)', n.nspname, c.relname, age(c.relfrozenxid)) AS table_name
        FROM pg_class c
        JOIN pg_namespace n
            ON n.oid = c.relnamespace
        WHERE c.relkind IN ('r', 'm')
          AND n.nspname ~ :'critical_schema_regex'
          AND age(c.relfrozenxid) > 1500000000
    )
    SELECT
        count(*)::bigint AS issue_count,
        COALESCE(
            (
                SELECT string_agg(table_name, ', ')
                FROM (
                    SELECT table_name
                    FROM risk
                    ORDER BY table_name
                    LIMIT 5
                ) AS s
            ),
            'none'
        ) AS sample_tables
    FROM risk
) AS x;

INSERT INTO tmp_takeover_gate_v3
SELECT
    'TG3-ACT-001',
    'Activity and Locks',
    true,
    CASE WHEN x.issue_count = 0 THEN 'PASS' ELSE 'FAIL' END,
    x.issue_count,
    'No transactions older than 30 minutes at takeover cut point',
    CASE
        WHEN x.issue_count = 0 THEN 'none'
        ELSE 'sample=' || x.sample_sessions
    END,
    'Close/terminate long transactions and fix app transaction boundaries.'
FROM (
    WITH long_x AS (
        SELECT
            format('pid=%s age=%s', pid, now() - xact_start) AS session_desc
        FROM pg_stat_activity
        WHERE xact_start IS NOT NULL
          AND pid <> pg_backend_pid()
          AND now() - xact_start > interval '30 minutes'
    )
    SELECT
        count(*)::bigint AS issue_count,
        COALESCE(
            (
                SELECT string_agg(session_desc, ', ')
                FROM (
                    SELECT session_desc
                    FROM long_x
                    ORDER BY session_desc
                    LIMIT 5
                ) AS s
            ),
            'none'
        ) AS sample_sessions
    FROM long_x
) AS x;

INSERT INTO tmp_takeover_gate_v3
SELECT
    'TG3-CAP-001',
    'Capacity',
    true,
    CASE
        WHEN x.usage_pct >= 95 THEN 'FAIL'
        WHEN x.usage_pct >= 85 THEN 'WARN'
        ELSE 'PASS'
    END,
    CASE
        WHEN x.usage_pct >= 85 THEN 1
        ELSE 0
    END,
    'Connection usage fail >=95%; warn >=85%',
    'current=' || x.current_connections || ' max=' || x.max_connections || ' usage_pct=' || x.usage_pct,
    'Apply connection pooling and cap app concurrency before cutover.'
FROM (
    WITH r AS (
        SELECT
            (SELECT count(*) FROM pg_stat_activity)::numeric AS current_connections,
            (SELECT setting::numeric FROM pg_settings WHERE name = 'max_connections') AS max_connections
    )
    SELECT
        current_connections,
        max_connections,
        round(100.0 * current_connections / NULLIF(max_connections, 0), 2) AS usage_pct
    FROM r
) AS x;

INSERT INTO tmp_takeover_gate_v3
SELECT
    'TG3-REP-001',
    'Replication and HA',
    true,
    CASE
        WHEN x.in_recovery THEN 'PASS'
        WHEN x.standby_count = 0 THEN 'WARN'
        WHEN x.max_lag_bytes > (5::numeric * 1024 * 1024 * 1024) THEN 'FAIL'
        WHEN x.max_lag_bytes > (1::numeric * 1024 * 1024 * 1024) THEN 'WARN'
        ELSE 'PASS'
    END,
    CASE
        WHEN x.in_recovery THEN 0
        WHEN x.standby_count = 0 THEN 1
        WHEN x.max_lag_bytes > (1::numeric * 1024 * 1024 * 1024) THEN 1
        ELSE 0
    END,
    'Primary lag fail >5GB; warn >1GB',
    CASE
        WHEN x.in_recovery THEN 'standby node'
        ELSE 'standbys=' || x.standby_count || ' max_lag=' || pg_size_pretty(x.max_lag_bytes::bigint)
    END,
    'Validate standby replay speed and HA topology readiness.'
FROM (
    WITH base AS (
        SELECT
            pg_is_in_recovery() AS in_recovery,
            CASE
                WHEN pg_is_in_recovery() THEN pg_last_wal_replay_lsn()
                ELSE pg_current_wal_lsn()
            END AS base_lsn
    )
    SELECT
        b.in_recovery,
        count(r.*)::bigint AS standby_count,
        COALESCE(max(pg_wal_lsn_diff(b.base_lsn, r.replay_lsn)), 0)::numeric AS max_lag_bytes
    FROM base b
    LEFT JOIN pg_stat_replication r
        ON TRUE
    GROUP BY b.in_recovery, b.base_lsn
) AS x;

INSERT INTO tmp_takeover_gate_v3
SELECT
    'TG3-WAL-001',
    'WAL and Checkpoints',
    false,
    CASE WHEN x.issue_count = 0 THEN 'PASS' ELSE 'WARN' END,
    x.issue_count,
    'Recommended baseline: max_wal_size>=4GB, checkpoint_timeout>=10min, checkpoint_completion_target>=0.90',
    x.evidence,
    'Tune checkpoint and WAL settings to reduce write spikes.'
FROM (
    WITH raw AS (
        SELECT
            (SELECT setting::numeric FROM pg_settings WHERE name = 'max_wal_size') AS max_wal_size_value,
            (SELECT unit FROM pg_settings WHERE name = 'max_wal_size') AS max_wal_size_unit,
            (SELECT setting::numeric FROM pg_settings WHERE name = 'checkpoint_timeout') AS checkpoint_timeout_value,
            (SELECT unit FROM pg_settings WHERE name = 'checkpoint_timeout') AS checkpoint_timeout_unit,
            (SELECT setting::numeric FROM pg_settings WHERE name = 'checkpoint_completion_target') AS checkpoint_completion_target
    ),
    n AS (
        SELECT
            CASE
                WHEN max_wal_size_unit = 'kB' THEN max_wal_size_value * 1024
                WHEN max_wal_size_unit = '8kB' THEN max_wal_size_value * 8192
                WHEN max_wal_size_unit = 'MB' THEN max_wal_size_value * 1024 * 1024
                WHEN max_wal_size_unit = 'GB' THEN max_wal_size_value * 1024 * 1024 * 1024
                WHEN max_wal_size_unit = 'B' THEN max_wal_size_value
                ELSE max_wal_size_value
            END AS max_wal_size_bytes,
            CASE
                WHEN checkpoint_timeout_unit = 'ms' THEN checkpoint_timeout_value / 1000
                WHEN checkpoint_timeout_unit = 's' THEN checkpoint_timeout_value
                WHEN checkpoint_timeout_unit = 'min' THEN checkpoint_timeout_value * 60
                ELSE checkpoint_timeout_value
            END AS checkpoint_timeout_seconds,
            checkpoint_completion_target
        FROM raw
    )
    SELECT
        (
            CASE WHEN max_wal_size_bytes < (4::numeric * 1024 * 1024 * 1024) THEN 1 ELSE 0 END
            +
            CASE WHEN checkpoint_timeout_seconds < 600 THEN 1 ELSE 0 END
            +
            CASE WHEN checkpoint_completion_target < 0.90 THEN 1 ELSE 0 END
        )::bigint AS issue_count,
        'max_wal_size=' || pg_size_pretty(max_wal_size_bytes::bigint)
        || ', checkpoint_timeout=' || round(checkpoint_timeout_seconds)::bigint || 's'
        || ', checkpoint_completion_target=' || checkpoint_completion_target AS evidence
    FROM n
) AS x;

\unset QUIET

\pset title 'V3 Takeover Gate Checks'
SELECT
    check_id,
    area,
    CASE WHEN is_blocker THEN 'YES' ELSE 'NO' END AS blocker,
    status,
    issue_count,
    threshold_rule,
    evidence,
    recommended_action
FROM tmp_takeover_gate_v3
ORDER BY
    CASE
        WHEN is_blocker AND status = 'FAIL' THEN 1
        WHEN status = 'FAIL' THEN 2
        WHEN status = 'WARN' THEN 3
        ELSE 4
    END,
    check_id;

\pset title 'V3 Takeover Gate Summary'
SELECT
    count(*) AS total_checks,
    count(*) FILTER (WHERE status = 'PASS') AS pass_checks,
    count(*) FILTER (WHERE status = 'WARN') AS warn_checks,
    count(*) FILTER (WHERE status = 'FAIL') AS fail_checks,
    count(*) FILTER (WHERE is_blocker AND status = 'FAIL') AS blocker_failures,
    CASE
        WHEN count(*) FILTER (WHERE is_blocker AND status = 'FAIL') > 0 THEN 'NO_GO'
        WHEN count(*) FILTER (WHERE status = 'WARN') > 0 THEN 'CONDITIONAL_GO'
        ELSE 'GO'
    END AS final_decision
FROM tmp_takeover_gate_v3;

SELECT
    CASE
        WHEN count(*) FILTER (WHERE is_blocker AND status = 'FAIL') > 0 THEN 'NO_GO'
        WHEN count(*) FILTER (WHERE status = 'WARN') > 0 THEN 'CONDITIONAL_GO'
        ELSE 'GO'
    END AS final_decision,
    count(*) FILTER (WHERE is_blocker AND status = 'FAIL') AS blocker_failures,
    count(*) FILTER (WHERE status = 'WARN') AS warning_checks,
    CASE
        WHEN count(*) FILTER (WHERE is_blocker AND status = 'FAIL') > 0 THEN 'true'
        ELSE 'false'
    END AS no_go
FROM tmp_takeover_gate_v3
\gset

\if :{?gate_output_file}
\o
\endif

\echo Gate Decision: :final_decision
\echo Blocker Failures: :blocker_failures
\echo Warning Checks: :warning_checks

\if :no_go
\echo NO_GO decision reached.
\if :enforce_exit
\echo Enforcing non-zero exit for CI/CD gate.
DO $$
BEGIN
    RAISE EXCEPTION 'Takeover gate NO_GO: blocker checks failed';
END;
$$;
\endif
\endif


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture file: /tmp/partition_new_outputs_20260218/09_takeover_gate.out.txt
--
-- Pager usage is off.
-- Border style is 1.
-- Title is "Takeover Gate Metadata (V3)".
--                                                                                             Takeover Gate Metadata (V3)
--  database_name | executed_by |                                                       postgres_version                                                       | critical_schema_regex |         evaluated_at          
-- ---------------+-------------+------------------------------------------------------------------------------------------------------------------------------+-----------------------+-------------------------------
--  pgbench_test  | saiendla    | PostgreSQL 18.0 (Homebrew) on aarch64-apple-darwin25.0.0, compiled by Apple clang version 17.0.0 (clang-1700.3.19.1), 64-bit | ^public$              | 2026-02-18 20:05:34.671993-05
-- (1 row)
-- 
-- Title is "V3 Takeover Gate Checks".
--                                                                                                                                                              V3 Takeover Gate Checks
--   check_id   |         area          | blocker | status | issue_count |                                             threshold_rule                                             |                                    evidence                                     |                               recommended_action                               
-- -------------+-----------------------+---------+--------+-------------+--------------------------------------------------------------------------------------------------------+---------------------------------------------------------------------------------+--------------------------------------------------------------------------------
--  TG3-OBJ-002 | Schema Design         | YES     | FAIL   |           1 | Large critical tables should have primary keys                                                         | sample=public.pgbench_history                                                   | Add PKs before takeover for integrity and operational safety.
--  TG3-STA-001 | Planner Statistics    | YES     | FAIL   |           1 | Large active tables should not have stale stats (mods >= 500k and analyze older than 1 day)            | sample=public.pgbench_accounts(mods=5332823)                                    | Run ANALYZE and tune autoanalyze thresholds before takeover.
--  TG3-REP-001 | Replication and HA    | YES     | WARN   |           1 | Primary lag fail >5GB; warn >1GB                                                                       | standbys=0 max_lag=0 bytes                                                      | Validate standby replay speed and HA topology readiness.
--  TG3-WAL-001 | WAL and Checkpoints   | NO      | WARN   |           2 | Recommended baseline: max_wal_size>=4GB, checkpoint_timeout>=10min, checkpoint_completion_target>=0.90 | max_wal_size=1024 MB, checkpoint_timeout=300s, checkpoint_completion_target=0.9 | Tune checkpoint and WAL settings to reduce write spikes.
--  TG3-ACT-001 | Activity and Locks    | YES     | PASS   |           0 | No transactions older than 30 minutes at takeover cut point                                            | none                                                                            | Close/terminate long transactions and fix app transaction boundaries.
--  TG3-CAP-001 | Capacity              | YES     | PASS   |           0 | Connection usage fail >=95%; warn >=85%                                                                | current=10 max=100 usage_pct=10.00                                              | Apply connection pooling and cap app concurrency before cutover.
--  TG3-CFG-001 | Configuration         | YES     | PASS   |           0 | autovacuum must be enabled                                                                             | autovacuum=on                                                                   | Enable autovacuum before takeover; validate table-level settings.
--  TG3-ENV-001 | Observability         | NO      | PASS   |           0 | pg_stat_statements should be installed for production SQL telemetry                                    | pg_stat_statements=installed                                                    | Install pg_stat_statements for Day-1 incident diagnostics and workload tuning.
--  TG3-OBJ-001 | Objects               | YES     | PASS   |           0 | No invalid/not-ready indexes allowed                                                                   | none                                                                            | Rebuild invalid indexes using REINDEX INDEX CONCURRENTLY where possible.
--  TG3-OBJ-003 | Referential Integrity | YES     | PASS   |           0 | High-volume FK relationships should have supporting indexes                                            | none                                                                            | Create indexes with FK columns as leading columns.
--  TG3-VAC-001 | Vacuum and Bloat      | YES     | PASS   |           0 | Large critical tables should not exceed dead tuple pressure (>=20% and dead_tup >=500k)                | none                                                                            | Run VACUUM (ANALYZE) and tune autovacuum scale factor/threshold.
--  TG3-XID-001 | Transaction Safety    | YES     | PASS   |           0 | No critical schema tables should exceed relfrozenxid age 1.5B                                          | none                                                                            | Run aggressive VACUUM FREEZE cycle before takeover.
-- (12 rows)
-- 
-- Title is "V3 Takeover Gate Summary".
--                                   V3 Takeover Gate Summary
--  total_checks | pass_checks | warn_checks | fail_checks | blocker_failures | final_decision 
-- --------------+-------------+-------------+-------------+------------------+----------------
--            12 |           8 |           2 |           2 |                2 | NO_GO
-- (1 row)
-- 
-- Gate Decision: NO_GO
-- Blocker Failures: 2
-- Warning Checks: 2
-- NO_GO decision reached.
-- SAMPLE_OUTPUT_END
