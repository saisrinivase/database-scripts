/*
PostgreSQL DBA Script: Query Capture Quality PGSS
Purpose: Verify pg_stat_statements capture quality and show whether query history is useful enough for tuning.
Area: Observability 360
Usage: Run before relying on top-query, missing-index, ORM, or resource-attribution scripts.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Requires pg_stat_statements extension in the current database for detailed output.
*/
SELECT (to_regclass('public.pg_stat_statements') IS NOT NULL OR to_regclass('pg_catalog.pg_stat_statements') IS NOT NULL OR to_regclass('pg_stat_statements') IS NOT NULL) AS has_pgss \gset

SELECT
    'pg_stat_statements_extension' AS check_name,
    CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN 'INSTALLED' ELSE 'NOT_INSTALLED' END AS status,
    'Extension must exist in this database.' AS purpose
UNION ALL
SELECT
    'shared_preload_libraries',
    current_setting('shared_preload_libraries', true),
    'Must include pg_stat_statements before the extension can collect statements.'
UNION ALL
SELECT
    'pg_stat_statements.track',
    current_setting('pg_stat_statements.track', true),
    'Controls whether top/all/nested statements are tracked.'
UNION ALL
SELECT
    'pg_stat_statements.max',
    current_setting('pg_stat_statements.max', true),
    'Too low can evict statements quickly and reduce history quality.'
UNION ALL
SELECT
    'pg_stat_statements.track_utility',
    current_setting('pg_stat_statements.track_utility', true),
    'Controls utility statement tracking.';

\if :has_pgss
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
    max(calls) AS max_calls_single_statement
FROM pg_stat_statements;

SELECT
    s.userid::regrole AS user_name,
    coalesce(d.datname, s.dbid::text) AS database_name,
    s.queryid,
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
LIMIT 25;
\else
SELECT
    'pg_stat_statements view not available in this database. Install extension and preload library, then re-run.' AS guidance;
\endif

-- SAMPLE_OUTPUT_BEGIN
-- check_name                   | status             | purpose
-- -----------------------------+--------------------+-----------------------------------------------
-- pg_stat_statements_extension | INSTALLED          | Extension must exist in this database.
-- shared_preload_libraries     | pg_stat_statements | Must include pg_stat_statements...
--
-- tracked_statement_count | total_calls | total_exec_ms | pgss_cache_hit_pct | temp_blks_written
-- ------------------------+-------------+---------------+--------------------+------------------
--                  153284 |  9283742211 |  182938123.44 |              99.11 |          1928374
-- SAMPLE_OUTPUT_END
