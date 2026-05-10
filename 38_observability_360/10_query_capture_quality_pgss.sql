/*
PostgreSQL DBA Script: Query Capture Quality PGSS
Purpose: Verify pg_stat_statements capture quality and show whether query history is useful enough for tuning.
Area: Observability 360
Usage: Run before relying on top-query, missing-index, ORM, or resource-attribution scripts in pgAdmin or psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Detailed output requires pg_stat_statements extension in the current database.
*/

CREATE TEMP TABLE IF NOT EXISTS obs360_pgss_quality_checks (
    check_name text,
    status text,
    purpose text,
    recommended_action text
);

CREATE TEMP TABLE IF NOT EXISTS obs360_pgss_summary (
    tracked_statement_count bigint,
    total_calls numeric,
    total_exec_ms numeric,
    weighted_mean_exec_ms numeric,
    shared_blks_read numeric,
    shared_blks_hit numeric,
    pgss_cache_hit_pct numeric,
    temp_blks_written numeric,
    wal_bytes numeric,
    max_calls_single_statement numeric,
    status text,
    recommended_action text
);

CREATE TEMP TABLE IF NOT EXISTS obs360_pgss_top_sql (
    user_name text,
    database_name text,
    queryid text,
    calls numeric,
    total_exec_ms numeric,
    mean_exec_ms numeric,
    rows numeric,
    shared_blks_read numeric,
    shared_blks_hit numeric,
    temp_blks_written numeric,
    wal_bytes numeric,
    query_sample text
);

TRUNCATE obs360_pgss_quality_checks;
TRUNCATE obs360_pgss_summary;
TRUNCATE obs360_pgss_top_sql;

INSERT INTO obs360_pgss_quality_checks
SELECT 'pg_stat_statements_extension',
       CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN 'INSTALLED' ELSE 'NOT_INSTALLED' END,
       'Extension must exist in this database.',
       'Run CREATE EXTENSION pg_stat_statements after shared_preload_libraries is configured.'
UNION ALL
SELECT 'shared_preload_libraries',
       coalesce(nullif(current_setting('shared_preload_libraries', true), ''), '(empty)'),
       'Must include pg_stat_statements before the extension can collect statements.',
       'Add pg_stat_statements and restart PostgreSQL if missing.'
UNION ALL
SELECT 'pg_stat_statements.track',
       coalesce(current_setting('pg_stat_statements.track', true), '(not available)'),
       'Controls whether top/all/nested statements are tracked.',
       'Usually all or top is preferred for DBA diagnostics.'
UNION ALL
SELECT 'pg_stat_statements.max',
       coalesce(current_setting('pg_stat_statements.max', true), '(not available)'),
       'Too low can evict statements quickly and reduce history quality.',
       'Increase if high churn causes important statements to disappear.'
UNION ALL
SELECT 'pg_stat_statements.track_utility',
       coalesce(current_setting('pg_stat_statements.track_utility', true), '(not available)'),
       'Controls utility statement tracking.',
       'Keep enabled when utility commands matter for operations review.';

DO $$
BEGIN
    IF to_regclass('public.pg_stat_statements') IS NOT NULL
       OR to_regclass('pg_catalog.pg_stat_statements') IS NOT NULL
       OR to_regclass('pg_stat_statements') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO obs360_pgss_summary
            SELECT
                count(*) AS tracked_statement_count,
                sum(calls) AS total_calls,
                round(sum(total_exec_time)::numeric, 2) AS total_exec_ms,
                round(sum(mean_exec_time * calls)::numeric / NULLIF(sum(calls), 0), 4) AS weighted_mean_exec_ms,
                sum(shared_blks_read) AS shared_blks_read,
                sum(shared_blks_hit) AS shared_blks_hit,
                round(100.0 * sum(shared_blks_hit) / NULLIF(sum(shared_blks_hit) + sum(shared_blks_read), 0), 2) AS pgss_cache_hit_pct,
                sum(temp_blks_written) AS temp_blks_written,
                sum(wal_bytes) AS wal_bytes,
                max(calls) AS max_calls_single_statement,
                CASE WHEN count(*) = 0 THEN 'NO_STATEMENTS' ELSE 'READY' END AS status,
                CASE WHEN count(*) = 0 THEN 'pg_stat_statements exists but has no captured statements yet.'
                     ELSE 'pg_stat_statements has captured workload history for tuning review.' END AS recommended_action
            FROM pg_stat_statements
        $sql$;

        EXECUTE $sql$
            INSERT INTO obs360_pgss_top_sql
            SELECT
                s.userid::regrole::text AS user_name,
                coalesce(d.datname, s.dbid::text) AS database_name,
                s.queryid::text,
                s.calls,
                round(s.total_exec_time::numeric, 2) AS total_exec_ms,
                round(s.mean_exec_time::numeric, 4) AS mean_exec_ms,
                s.rows,
                s.shared_blks_read,
                s.shared_blks_hit,
                s.temp_blks_written,
                s.wal_bytes,
                left(regexp_replace(s.query, '\s+', ' ', 'g'), 160) AS query_sample
            FROM pg_stat_statements s
            LEFT JOIN pg_database d ON d.oid = s.dbid
            ORDER BY s.total_exec_time DESC
            LIMIT 25
        $sql$;
    ELSE
        INSERT INTO obs360_pgss_summary
        VALUES (
            0, 0, 0, NULL, 0, 0, NULL, 0, 0, 0,
            'PG_STAT_STATEMENTS_NOT_AVAILABLE',
            'Install/preload pg_stat_statements, then rerun this script.'
        );
    END IF;
END $$;

SELECT
    'step_01_pgss_readiness' AS report_section,
    check_name,
    status,
    purpose,
    recommended_action
FROM obs360_pgss_quality_checks
ORDER BY check_name;

SELECT
    'step_02_pgss_capture_summary' AS report_section,
    tracked_statement_count,
    total_calls,
    total_exec_ms,
    weighted_mean_exec_ms,
    shared_blks_read,
    shared_blks_hit,
    pgss_cache_hit_pct,
    temp_blks_written,
    wal_bytes,
    max_calls_single_statement,
    status,
    recommended_action
FROM obs360_pgss_summary;

SELECT
    'step_03_pgss_top_sql' AS report_section,
    user_name,
    database_name,
    queryid,
    calls,
    total_exec_ms,
    mean_exec_ms,
    rows,
    shared_blks_read,
    shared_blks_hit,
    temp_blks_written,
    wal_bytes,
    query_sample
FROM obs360_pgss_top_sql
ORDER BY total_exec_ms DESC NULLS LAST
LIMIT 25;

-- SAMPLE_OUTPUT_BEGIN
-- report_section         | check_name                   | status
-- -----------------------+------------------------------+--------------------
-- step_01_pgss_readiness | pg_stat_statements_extension | INSTALLED
--
-- report_section               | tracked_statement_count | total_calls | status
-- -----------------------------+-------------------------+-------------+--------
-- step_02_pgss_capture_summary |                  153284 |  9283742211 | READY
-- SAMPLE_OUTPUT_END
