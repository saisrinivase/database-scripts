/*
PostgreSQL DBA Script: Top 10 Temp Disk Spill Queries PgAdmin
Purpose: Rank statements writing the most temporary blocks, commonly caused by sort/hash/materialize spills.
Area: Performance Tuning
Usage: Run in pgAdmin, psql, or any SQL client after pg_stat_statements is installed in the current database.
       Optional filter:
       SELECT set_config('pgdiag.min_temp_pct','40',false); -- show only SQL >= 40% of temp spill blocks
       -- Optional timestamp placeholders when using your own pg_stat_statements snapshot table:
       -- AND snapshot_ts >= timestamp '2026-05-10 09:00:00'
       -- AND snapshot_ts <  timestamp '2026-05-10 10:00:00'
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Temp blocks are cumulative since pg_stat_statements reset and use the server block_size, usually 8kB.
*/
WITH params AS (
    SELECT coalesce(nullif(current_setting('pgdiag.min_temp_pct', true), '')::numeric, 0) AS min_temp_pct
),
base AS (
    SELECT s.*
    FROM pg_stat_statements s
    WHERE s.temp_blks_read + s.temp_blks_written > 0
),
totals AS (
    SELECT sum(temp_blks_read + temp_blks_written) AS total_temp_blks
    FROM base
)
SELECT
    coalesce(r.rolname, s.userid::text) AS user_name,
    coalesce(d.datname, s.dbid::text) AS database_name,
    s.queryid,
    s.calls,
    s.temp_blks_read,
    s.temp_blks_written,
    (s.temp_blks_read + s.temp_blks_written) AS temp_blks_total,
    round((100.0 * (s.temp_blks_read + s.temp_blks_written) / NULLIF(t.total_temp_blks, 0))::numeric, 2) AS pct_temp_spill_load,
    pg_size_pretty(((s.temp_blks_read + s.temp_blks_written) * current_setting('block_size')::bigint)) AS temp_total_pretty,
    pg_size_pretty((s.temp_blks_written * current_setting('block_size')::bigint)) AS temp_written_pretty,
    round((((s.temp_blks_read + s.temp_blks_written) * current_setting('block_size')::numeric) / NULLIF(s.calls, 0)), 2) AS temp_bytes_per_call,
    round(s.total_exec_time::numeric, 2) AS total_exec_ms,
    round(s.mean_exec_time::numeric, 4) AS mean_exec_ms,
    s.rows,
    round((s.rows::numeric / NULLIF(s.calls, 0)), 2) AS rows_per_call,
    s.shared_blks_read,
    s.shared_blks_hit,
    CASE
        WHEN s.temp_blks_written > 0 AND s.calls <= 10 THEN 'Few large spill events; inspect plan for big sort/hash/aggregate.'
        WHEN s.temp_blks_written > 0 AND s.calls > 1000 THEN 'Frequent spill pattern; tune SQL, indexes, work_mem scope, or batching.'
        WHEN s.temp_blks_read > s.temp_blks_written THEN 'Repeated temp rereads; inspect multi-pass sorts/hashes.'
        ELSE 'Review execution plan and work_mem-sensitive operators.'
    END AS sme_diagnosis,
    regexp_replace(s.query, '\s+', ' ', 'g') AS query_sample
FROM base s
CROSS JOIN totals t
LEFT JOIN pg_roles r ON r.oid = s.userid
LEFT JOIN pg_database d ON d.oid = s.dbid
WHERE round((100.0 * (s.temp_blks_read + s.temp_blks_written) / NULLIF(t.total_temp_blks, 0))::numeric, 2) >= (SELECT min_temp_pct FROM params)
ORDER BY temp_blks_total DESC, s.total_exec_time DESC
LIMIT 10;

-- SAMPLE_OUTPUT_BEGIN
-- user_name | database_name | queryid | calls | temp_blks_written | pct_temp_spill_load | temp_total_pretty | temp_bytes_per_call | sme_diagnosis
-- ----------+---------------+---------+-------+-------------------+---------------------+-------------------+---------------------+-----------------------------------------
-- app_user  | appdb         | 456789  |    12 |           8847360 |               42.5 | 68 GB             |       6081740800.00 | Few large spill events; inspect plan...
-- SAMPLE_OUTPUT_END
