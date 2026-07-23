/*
PostgreSQL DBA Script: Object Query Hotspots Pg Stat Statements
Purpose: Show top query hotspots with coarse object token extraction from SQL text.
Area: Object Inventory and Health
Usage: Requires pg_stat_statements for query-level output. Safe for pgAdmin and psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic.
*/
CREATE TEMP TABLE IF NOT EXISTS object_query_hotspots_pgss_result (
    queryid bigint,
    calls bigint,
    total_exec_time_ms numeric,
    mean_exec_time_ms numeric,
    rows bigint,
    shared_blks_read bigint,
    shared_blks_hit bigint,
    temp_blks_written bigint,
    possible_object text,
    query_snippet text
);

TRUNCATE object_query_hotspots_pgss_result;

DO $$
BEGIN
    IF to_regclass('pg_stat_statements') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO object_query_hotspots_pgss_result
            WITH ranked AS (
                SELECT
                    s.queryid,
                    s.calls,
                    s.total_exec_time,
                    s.mean_exec_time,
                    s.rows,
                    s.shared_blks_read,
                    s.shared_blks_hit,
                    s.temp_blks_written,
                    regexp_replace(s.query, '\s+', ' ', 'g') AS query_snippet,
                    coalesce(
                        substring(lower(s.query) FROM 'from[[:space:]]+([a-z0-9_."$]+)'),
                        substring(lower(s.query) FROM 'join[[:space:]]+([a-z0-9_."$]+)')
                    ) AS object_token
                FROM pg_stat_statements s
            )
            SELECT
                queryid,
                calls,
                round(total_exec_time::numeric, 2),
                round(mean_exec_time::numeric, 2),
                rows,
                shared_blks_read,
                shared_blks_hit,
                temp_blks_written,
                coalesce(object_token, '(unparsed)'),
                query_snippet
            FROM ranked
            ORDER BY total_exec_time DESC
            LIMIT 150
        $sql$;
    ELSE
        INSERT INTO object_query_hotspots_pgss_result(query_snippet)
        VALUES ('pg_stat_statements extension is not installed. Run CREATE EXTENSION pg_stat_statements after preload is configured.');
    END IF;
END $$;

SELECT *
FROM object_query_hotspots_pgss_result;

-- SAMPLE_OUTPUT_BEGIN
-- queryid | calls | total_exec_time_ms | possible_object | query_snippet
-- --------+-------+--------------------+-----------------+--------------
-- 12345   | 1000  |           50000.00 | app.orders      | SELECT ...
-- SAMPLE_OUTPUT_END
