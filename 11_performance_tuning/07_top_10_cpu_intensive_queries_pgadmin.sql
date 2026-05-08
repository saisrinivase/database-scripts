/*
PostgreSQL DBA Script: Top 10 CPU Intensive Queries PgAdmin
Purpose: Rank the top CPU-heavy SQL statements using pg_stat_statements execution time and low temp/I/O block footprint.
Area: Performance Tuning
Usage: Run in pgAdmin, psql, or any SQL client after pg_stat_statements is installed in the current database.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. PostgreSQL does not expose exact per-query CPU in core SQL; this uses CPU-like pressure from total execution time, calls, block footprint, and temp footprint.
*/
WITH pgss AS (
    SELECT
        s.userid,
        s.dbid,
        s.queryid,
        s.calls,
        s.total_exec_time,
        s.mean_exec_time,
        s.min_exec_time,
        s.max_exec_time,
        s.stddev_exec_time,
        s.rows,
        s.shared_blks_hit,
        s.shared_blks_read,
        s.shared_blks_dirtied,
        s.shared_blks_written,
        s.local_blks_hit,
        s.local_blks_read,
        s.local_blks_dirtied,
        s.local_blks_written,
        s.temp_blks_read,
        s.temp_blks_written,
        s.wal_bytes,
        s.query
    FROM pg_stat_statements s
)
SELECT
    coalesce(r.rolname, pgss.userid::text) AS user_name,
    coalesce(d.datname, pgss.dbid::text) AS database_name,
    pgss.queryid,
    pgss.calls,
    round(pgss.total_exec_time::numeric, 2) AS total_exec_ms,
    round(pgss.total_exec_time::numeric, 2) AS cpu_like_exec_ms,
    round((100.0 * pgss.shared_blks_hit / NULLIF(pgss.shared_blks_hit + pgss.shared_blks_read + pgss.temp_blks_read + pgss.temp_blks_written, 0))::numeric, 2) AS cache_or_cpu_work_pct,
    round(pgss.mean_exec_time::numeric, 4) AS mean_exec_ms,
    round(pgss.max_exec_time::numeric, 2) AS max_exec_ms,
    round(pgss.stddev_exec_time::numeric, 2) AS stddev_exec_ms,
    pgss.rows,
    round((pgss.rows::numeric / NULLIF(pgss.calls, 0)), 2) AS rows_per_call,
    pgss.shared_blks_hit,
    pgss.shared_blks_read,
    pgss.temp_blks_written,
    pg_size_pretty((pgss.temp_blks_written * current_setting('block_size')::bigint)) AS temp_written_pretty,
    pg_size_pretty(coalesce(pgss.wal_bytes, 0)::bigint) AS wal_bytes_pretty,
    CASE
        WHEN pgss.calls > 10000 AND pgss.mean_exec_time < 10 THEN 'High-frequency CPU workload; check app batching and indexes.'
        WHEN pgss.stddev_exec_time > pgss.mean_exec_time THEN 'Runtime variance; check plan instability, parameter skew, or cache effects.'
        WHEN pgss.shared_blks_read = 0 AND pgss.temp_blks_written = 0 THEN 'Likely CPU-bound; inspect functions, joins, sorts, expressions, and plan rows.'
        ELSE 'Mixed CPU/IO profile; compare with IO and temp spill scripts.'
    END AS sme_diagnosis,
    left(regexp_replace(pgss.query, '\s+', ' ', 'g'), 220) AS query_sample
FROM pgss
LEFT JOIN pg_roles r ON r.oid = pgss.userid
LEFT JOIN pg_database d ON d.oid = pgss.dbid
ORDER BY pgss.total_exec_time DESC NULLS LAST
LIMIT 10;

-- SAMPLE_OUTPUT_BEGIN
-- user_name | database_name | queryid | calls | total_exec_ms | cpu_like_exec_ms | cache_or_cpu_work_pct | mean_exec_ms | sme_diagnosis
-- ----------+---------------+---------+-------+---------------+------------------+-----------------------+--------------+--------------------------------------------
-- app_user  | appdb         | 123456  | 84000 |     920000.00 |        920000.00 |                 96.74 |      10.9524 | Likely CPU-bound; inspect functions...
-- SAMPLE_OUTPUT_END
