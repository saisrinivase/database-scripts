/*
PostgreSQL DBA Script: Safe pgstattuple Bloat Candidates
Purpose: Rank likely table-bloat candidates and generate opt-in pgstattuple_approx() commands without scanning table data automatically.
Area: Vacuum and Bloat
Usage: Run on the writer because dead-tuple and modification statistics are writer-local. Review candidates, then run one generated command at a time during a low-load window.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only. The report itself uses statistics and relation-size metadata only. It never invokes pgstattuple() or pgstattuple_approx().
       pgstattuple() performs an exact full-table scan and is intentionally not generated for large production tables.
*/
WITH extension_status AS (
    SELECT
        EXISTS (
            SELECT 1
            FROM pg_extension
            WHERE extname = 'pgstattuple'
        ) AS is_installed,
        EXISTS (
            SELECT 1
            FROM pg_available_extensions
            WHERE name = 'pgstattuple'
        ) AS is_available
),
candidates AS (
    SELECT
        s.relid,
        s.schemaname,
        s.relname,
        pg_total_relation_size(s.relid) AS total_bytes,
        s.n_live_tup,
        s.n_dead_tup,
        s.n_mod_since_analyze,
        s.last_autovacuum,
        s.last_autoanalyze,
        CASE
            WHEN s.n_live_tup + s.n_dead_tup = 0 THEN 0
            ELSE round(100.0 * s.n_dead_tup / (s.n_live_tup + s.n_dead_tup), 2)
        END AS estimated_dead_tuple_pct
    FROM pg_stat_user_tables s
    WHERE s.n_dead_tup >= 10000
       OR (
            s.n_live_tup + s.n_dead_tup > 0
            AND 100.0 * s.n_dead_tup / (s.n_live_tup + s.n_dead_tup) >= 10
       )
),
ranked AS (
    SELECT *
    FROM candidates
    ORDER BY estimated_dead_tuple_pct DESC, total_bytes DESC
    LIMIT 25
)
SELECT
    r.schemaname,
    r.relname,
    pg_size_pretty(r.total_bytes) AS total_size,
    r.n_live_tup,
    r.n_dead_tup,
    r.estimated_dead_tuple_pct,
    r.n_mod_since_analyze,
    r.last_autovacuum,
    r.last_autoanalyze,
    CASE
        WHEN NOT e.is_available THEN 'PGSTATTUPLE_NOT_AVAILABLE_ON_SERVER'
        WHEN NOT e.is_installed THEN 'INSTALL_EXTENSION_FIRST'
        ELSE 'READY_FOR_OPT_IN_APPROX_CHECK'
    END AS readiness,
    CASE
        WHEN e.is_installed THEN format(
            'SET statement_timeout = ''5min''; SELECT * FROM pgstattuple_approx(%L::regclass);',
            format('%I.%I', r.schemaname, r.relname)
        )
        WHEN e.is_available THEN 'CREATE EXTENSION IF NOT EXISTS pgstattuple;'
        ELSE 'Install the pgstattuple package or enable the managed-service extension.'
    END AS reviewed_next_command
FROM ranked r
CROSS JOIN extension_status e
ORDER BY r.estimated_dead_tuple_pct DESC, r.total_bytes DESC;

-- SAMPLE_OUTPUT_BEGIN
-- schemaname | relname     | total_size | estimated_dead_tuple_pct | readiness
-- public     | order_event | 48 GB      | 27.51                    | READY_FOR_OPT_IN_APPROX_CHECK
-- SAMPLE_OUTPUT_END
