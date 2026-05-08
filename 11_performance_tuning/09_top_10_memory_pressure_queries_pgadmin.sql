/*
PostgreSQL DBA Script: Top 10 Memory Pressure Queries PgAdmin
Purpose: Identify queries most likely to create memory pressure using temp spills, high rows per call, block churn, and runtime variance.
Area: Performance Tuning
Usage: Run in pgAdmin, psql, or any SQL client after pg_stat_statements is installed in the current database.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. PostgreSQL core does not expose exact historical per-query memory usage; this script ranks memory-pressure proxies.
*/
WITH settings AS (
    SELECT
        current_setting('block_size')::numeric AS block_size_bytes,
        pg_size_bytes(current_setting('work_mem'))::numeric AS work_mem_bytes,
        pg_size_bytes(current_setting('maintenance_work_mem'))::numeric AS maintenance_work_mem_bytes,
        current_setting('hash_mem_multiplier', true)::numeric AS hash_mem_multiplier
),
ranked AS (
    SELECT
        s.*,
        ((s.temp_blks_read + s.temp_blks_written) * settings.block_size_bytes) AS temp_bytes_total,
        (s.temp_blks_written * settings.block_size_bytes) AS temp_bytes_written,
        (s.shared_blks_hit + s.shared_blks_read + s.local_blks_hit + s.local_blks_read) AS total_blocks_touched,
        settings.work_mem_bytes,
        settings.hash_mem_multiplier,
        (
            ((s.temp_blks_read + s.temp_blks_written) * settings.block_size_bytes)
            + greatest(s.rows, 0)::numeric
            + ((s.shared_blks_hit + s.shared_blks_read + s.local_blks_hit + s.local_blks_read) * settings.block_size_bytes * 0.01)
            + greatest(s.stddev_exec_time, 0)::numeric * 1024
        ) AS memory_pressure_score
    FROM pg_stat_statements s
    CROSS JOIN settings
)
SELECT
    coalesce(r.rolname, ranked.userid::text) AS user_name,
    coalesce(d.datname, ranked.dbid::text) AS database_name,
    ranked.queryid,
    ranked.calls,
    round(ranked.memory_pressure_score::numeric, 2) AS memory_pressure_score,
    pg_size_pretty(ranked.temp_bytes_total::bigint) AS temp_total_pretty,
    pg_size_pretty(ranked.temp_bytes_written::bigint) AS temp_written_pretty,
    round((ranked.temp_bytes_total / NULLIF(ranked.calls, 0)), 2) AS temp_bytes_per_call,
    ranked.rows,
    round((ranked.rows::numeric / NULLIF(ranked.calls, 0)), 2) AS rows_per_call,
    ranked.total_blocks_touched,
    round(ranked.total_exec_time::numeric, 2) AS total_exec_ms,
    round(ranked.mean_exec_time::numeric, 4) AS mean_exec_ms,
    round(ranked.stddev_exec_time::numeric, 2) AS stddev_exec_ms,
    pg_size_pretty(ranked.work_mem_bytes::bigint) AS current_work_mem,
    ranked.hash_mem_multiplier,
    CASE
        WHEN ranked.temp_bytes_total > ranked.work_mem_bytes * 100 THEN 'Severe spill proxy; inspect sort/hash/aggregate nodes and avoid broad work_mem changes.'
        WHEN ranked.temp_bytes_total > 0 THEN 'Spill proxy; review plan, row estimates, indexes, and per-session work_mem only if justified.'
        WHEN ranked.rows / NULLIF(ranked.calls, 0) > 100000 THEN 'Large rows-per-call; check result size, aggregation, joins, and pagination.'
        WHEN ranked.stddev_exec_time > ranked.mean_exec_time THEN 'Runtime variance; check parameter-sensitive memory usage and plan changes.'
        ELSE 'Memory proxy signal; validate with EXPLAIN (ANALYZE, BUFFERS).'
    END AS sme_diagnosis,
    left(regexp_replace(ranked.query, '\s+', ' ', 'g'), 220) AS query_sample
FROM ranked
LEFT JOIN pg_roles r ON r.oid = ranked.userid
LEFT JOIN pg_database d ON d.oid = ranked.dbid
WHERE ranked.temp_bytes_total > 0
   OR ranked.rows / NULLIF(ranked.calls, 0) > 100000
   OR ranked.total_blocks_touched > 1000000
ORDER BY ranked.memory_pressure_score DESC NULLS LAST
LIMIT 10;

-- SAMPLE_OUTPUT_BEGIN
-- user_name | database_name | queryid | calls | memory_pressure_score | temp_total_pretty | current_work_mem | sme_diagnosis
-- ----------+---------------+---------+-------+-----------------------+-------------------+------------------+---------------------------------------------
-- app_user  | appdb         | 987654  |    24 |        73400320000.00 | 68 GB             | 4 MB             | Severe spill proxy; inspect sort/hash...
-- SAMPLE_OUTPUT_END
