/*
PostgreSQL DBA Script: Top 10 Memory Pressure Queries PgAdmin
Purpose: Identify the top SQL statements spilling to temporary files using plain PostgreSQL statistics views.
Area: Performance Tuning
Usage: Run in pgAdmin, psql, or any SQL client after pg_stat_statements is installed in the current database.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Uses only pg_stat_statements, pg_roles, pg_database, and current_setting().
       PostgreSQL does not expose exact historical per-query memory allocation; temp blocks are the strongest SQL-visible spill signal.
*/
SELECT
    coalesce(r.rolname, s.userid::text) AS user_name,
    coalesce(d.datname, s.dbid::text) AS database_name,
    s.queryid,
    regexp_replace(s.query, '\s+', ' ', 'g') AS query_text,
    s.calls,
    s.temp_blks_read,
    s.temp_blks_written,
    (s.temp_blks_read + s.temp_blks_written) AS temp_blks_total,
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
    left(regexp_replace(s.query, '\s+', ' ', 'g'), 220) AS query_sample
FROM pg_stat_statements s
LEFT JOIN pg_roles r ON r.oid = s.userid
LEFT JOIN pg_database d ON d.oid = s.dbid
WHERE s.temp_blks_read + s.temp_blks_written > 0
ORDER BY temp_blks_total DESC, s.total_exec_time DESC
LIMIT 10;

-- SAMPLE_OUTPUT_BEGIN
-- user_name | database_name | queryid | query_text | calls | temp_blks_written | temp_blks_total | temp_total_pretty | temp_bytes_per_call | sme_diagnosis
-- ----------+---------------+---------+------------+-------+-------------------+-----------------+-------------------+---------------------+---------------------------------------------
-- app_user  | appdb         | 987654  | SELECT ... |    24 |           8388608 |         8388608 | 64 GB             |       2863311530.67 | Few large spill events; inspect plan...
-- SAMPLE_OUTPUT_END
