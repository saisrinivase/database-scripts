/*
PostgreSQL DBA Script: Top 10 CPU Intensive Queries PgAdmin
Purpose: Rank CPU candidates using pg_stat_statements execution time and low temp/buffer-miss footprint for OS and wait-event corroboration.
Area: Performance Tuning
Usage: Run in pgAdmin, psql, or any SQL client after pg_stat_statements is installed in the current database.
       Optional filter:
       SELECT set_config('pgdiag.min_cpu_pct','30',false); -- show only SQL >= 30% of total exec time
       -- Optional timestamp placeholders when using your own pg_stat_statements snapshot table:
       -- AND snapshot_ts >= timestamp '2026-05-10 09:00:00'
       -- AND snapshot_ts <  timestamp '2026-05-10 10:00:00'
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. PostgreSQL does not expose exact per-query CPU in core SQL. Execution time includes lock, client, and I/O waits, and shared-buffer hits are not CPU time. Confirm with live waits plus OS/per-process CPU profiling.
*/
WITH params AS (
    SELECT coalesce(nullif(current_setting('pgdiag.min_cpu_pct', true), '')::numeric, 0) AS min_cpu_pct
),
pgss AS (
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
),
totals AS (
    SELECT sum(total_exec_time) AS total_exec_time_all
    FROM pgss
)
SELECT
    psi.stats_reset AS statistics_since,
    clock_timestamp() - psi.stats_reset AS statistics_age,
    coalesce(r.rolname, pgss.userid::text) AS user_name,
    coalesce(d.datname, pgss.dbid::text) AS database_name,
    pgss.queryid,
    pgss.calls,
    round(pgss.total_exec_time::numeric, 2) AS total_exec_ms,
    round(pgss.total_exec_time::numeric, 2) AS cpu_like_exec_ms,
    round((100.0 * pgss.total_exec_time / NULLIF(t.total_exec_time_all, 0))::numeric, 2) AS pct_cpu_like_exec_time,
    round((100.0 * pgss.shared_blks_hit / NULLIF(pgss.shared_blks_hit + pgss.shared_blks_read, 0))::numeric, 2) AS shared_hit_share_pct,
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
        WHEN pgss.calls > 10000 AND pgss.mean_exec_time < 10 THEN 'High-frequency execution candidate; corroborate backend CPU and waits, then check batching and indexes.'
        WHEN pgss.stddev_exec_time > pgss.mean_exec_time THEN 'Runtime variance; check plan instability, parameter skew, or cache effects.'
        WHEN pgss.shared_blks_read = 0 AND pgss.temp_blks_written = 0 THEN 'CPU candidate with low SQL-visible read/spill footprint; exclude lock/client waits and confirm with OS CPU.'
        ELSE 'Mixed execution profile; compare wait events, block timing, temp spill, and OS CPU over the same interval.'
    END AS sme_diagnosis,
    regexp_replace(pgss.query, '\s+', ' ', 'g') AS query_sample
FROM pgss
CROSS JOIN totals t
CROSS JOIN pg_stat_statements_info psi
LEFT JOIN pg_roles r ON r.oid = pgss.userid
LEFT JOIN pg_database d ON d.oid = pgss.dbid
WHERE round((100.0 * pgss.total_exec_time / NULLIF(t.total_exec_time_all, 0))::numeric, 2) >= (SELECT min_cpu_pct FROM params)
ORDER BY pgss.total_exec_time DESC NULLS LAST
LIMIT 10;

-- SAMPLE_OUTPUT_BEGIN
-- user_name | database_name | queryid | calls | total_exec_ms | pct_cpu_like_exec_time | shared_hit_share_pct | mean_exec_ms | sme_diagnosis
-- ----------+---------------+---------+-------+---------------+------------------------+-----------------------+--------------+--------------------------------------------
-- app_user  | appdb         | 123456  | 84000 |     920000.00 |                  31.44 |                 96.74 |      10.9524 | CPU candidate; corroborate OS CPU and waits...
-- SAMPLE_OUTPUT_END
