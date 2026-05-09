/*
Purpose: pgAdmin-safe pg_stat_statements capture quality and top query pressure view.
Scope: Confirms whether pg_stat_statements is usable, then surfaces slow, temp-spilling, WAL-heavy, and frequently called SQL.
pgAdmin: Safe to run in Query Tool. Uses a temporary helper function only.
Sample output:
 section        | queryid | calls | total_exec_ms | temp_mb | wal_mb | diagnosis
----------------+---------+-------+---------------+---------+--------+--------------------------
 top total time | 12345   | 1000  | 245000.33     | 512.00  | 80.50  | Tune highest DB time SQL.
*/

CREATE OR REPLACE FUNCTION pg_temp.pgadmin_pgss_quality()
RETURNS TABLE (
    section text,
    database_name text,
    user_name text,
    queryid text,
    calls bigint,
    total_exec_ms numeric,
    mean_exec_ms numeric,
    rows_per_call numeric,
    shared_read_mb numeric,
    temp_mb numeric,
    wal_mb numeric,
    query_sample text,
    diagnosis text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF to_regclass('pg_stat_statements') IS NULL THEN
        RETURN QUERY
        SELECT
            'pg_stat_statements unavailable'::text,
            current_database()::text,
            current_user::text,
            NULL::text,
            NULL::bigint,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::text,
            'Install/enable pg_stat_statements in shared_preload_libraries and CREATE EXTENSION in the database.'::text;
        RETURN;
    END IF;

    RETURN QUERY EXECUTE
    $sql$
        WITH ranked AS (
            SELECT
                'top total time'::text AS section,
                d.datname::text AS database_name,
                r.rolname::text AS user_name,
                s.queryid::text,
                s.calls,
                round(s.total_exec_time::numeric, 2) AS total_exec_ms,
                round(s.mean_exec_time::numeric, 2) AS mean_exec_ms,
                round((s.rows::numeric / NULLIF(s.calls, 0)), 2) AS rows_per_call,
                round(((s.shared_blks_read * current_setting('block_size')::numeric) / 1024 / 1024), 2) AS shared_read_mb,
                round((((s.temp_blks_read + s.temp_blks_written) * current_setting('block_size')::numeric) / 1024 / 1024), 2) AS temp_mb,
                round((s.wal_bytes::numeric / 1024 / 1024), 2) AS wal_mb,
                left(regexp_replace(s.query, '\s+', ' ', 'g'), 220)::text AS query_sample,
                CASE
                    WHEN (s.temp_blks_read + s.temp_blks_written) > 0
                        THEN 'Temp spill. Review work_mem, sort/hash plans, missing indexes, and row estimates.'
                    WHEN s.wal_bytes > 1024 * 1024 * 1024
                        THEN 'WAL-heavy SQL. Review bulk writes, indexes, batch size, and checkpoint/WAL capacity.'
                    WHEN s.mean_exec_time > 1000
                        THEN 'High mean latency. Capture EXPLAIN ANALYZE and validate indexes/statistics.'
                    WHEN s.shared_blks_read > s.shared_blks_hit
                        THEN 'Read-heavy SQL. Check indexes, cache residency, and table/index bloat.'
                    ELSE 'High database time. Tune by execution plan and business criticality.'
                END::text AS diagnosis,
                row_number() OVER (ORDER BY s.total_exec_time DESC) AS rn
            FROM pg_stat_statements s
            LEFT JOIN pg_database d ON d.oid = s.dbid
            LEFT JOIN pg_roles r ON r.oid = s.userid
            WHERE s.calls > 0
        )
        SELECT
            section,
            database_name,
            user_name,
            queryid,
            calls,
            total_exec_ms,
            mean_exec_ms,
            rows_per_call,
            shared_read_mb,
            temp_mb,
            wal_mb,
            query_sample,
            diagnosis
        FROM ranked
        WHERE rn <= 25
        ORDER BY total_exec_ms DESC NULLS LAST
    $sql$;
END;
$$;

SELECT *
FROM pg_temp.pgadmin_pgss_quality();

-- SAMPLE_OUTPUT_BEGIN
-- section        | database_name | user_name | queryid | calls | total_exec_ms | temp_mb | wal_mb | diagnosis
-- --------------+---------------+-----------+---------+-------+---------------+---------+--------+------------------------------
-- top total time | appdb         | app_user  | 12345   | 1000  | 245000.33     | 512.00  | 80.50  | Temp spill...
-- SAMPLE_OUTPUT_END
