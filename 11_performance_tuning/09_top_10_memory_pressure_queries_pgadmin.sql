/*
PostgreSQL DBA Script: Top 10 Memory and Temp Spill Churn Queries PgAdmin
Purpose: Prioritize SQL statements with temp-file spill churn; this is not a measurement of total query memory allocation.
Area: Performance Tuning
Usage: Run in pgAdmin, psql, or any SQL client after pg_stat_statements is installed in the current database.
       Optional filter:
       SELECT set_config('pgdiag.min_temp_spill_pct','40',false); -- show only SQL >= 40% of temp spill load
       SELECT set_config('pgdiag.query_filter','',false);          -- optional query-text filter
       SELECT set_config('pgdiag.include_noise','off',false);      -- include EXPLAIN/maintenance/diagnostic SQL when on
       -- Optional timestamp placeholders when using your own pg_stat_statements snapshot table:
       -- AND snapshot_ts >= timestamp '2026-05-10 09:00:00'
       -- AND snapshot_ts <  timestamp '2026-05-10 10:00:00'
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. PostgreSQL does not expose exact historical per-query memory allocation; temp blocks
       measure spill I/O caused by memory-sensitive operators. Never raise global work_mem from this report alone.
*/
WITH params AS (
    SELECT coalesce(
        nullif(current_setting('pgdiag.min_temp_spill_pct', true), '')::numeric,
        nullif(current_setting('pgdiag.min_memory_pct', true), '')::numeric,
        0
    ) AS min_temp_spill_pct,
    coalesce(nullif(current_setting('pgdiag.query_filter', true), ''), '') AS query_filter,
    coalesce(nullif(current_setting('pgdiag.include_noise', true), '')::boolean, false) AS include_noise
),
base AS (
    SELECT
        s.*,
        coalesce(d.datname, s.dbid::text) AS database_name,
        (s.temp_blks_read + s.temp_blks_written) AS temp_blocks,
        (s.temp_blks_read + s.temp_blks_written) * current_setting('block_size')::numeric AS temp_bytes,
        ((s.temp_blks_read + s.temp_blks_written) * current_setting('block_size')::numeric)
            / NULLIF(s.calls, 0) AS temp_bytes_per_call
    FROM pg_stat_statements s
    LEFT JOIN pg_database d ON d.oid = s.dbid
    CROSS JOIN params p
    WHERE s.temp_blks_read + s.temp_blks_written > 0
      AND (p.query_filter = '' OR s.query ILIKE '%' || p.query_filter || '%')
      AND (
          p.include_noise
          OR s.query !~* '^\s*(explain|analyze|vacuum|create\s+(temp(orary)?\s+)?(index|table)|do\s+\$\$)(\s|$)'
      )
      AND (
          p.include_noise
          OR s.query !~* '(pg_stat_statements|obs360_|dba_live\.|pg_temp\.|pg_show_all_settings|pg_settings)'
      )
),
totals AS (
    SELECT sum(temp_blocks) AS total_temp_blocks
    FROM base
),
scored AS (
    SELECT
        b.*,
        100.0 * b.temp_blocks / NULLIF(t.total_temp_blocks, 0) AS temp_spill_pct,
        CASE
            WHEN b.temp_bytes >= 10::numeric * 1024 * 1024 * 1024
              OR b.temp_bytes_per_call >= 1024::numeric * 1024 * 1024
                THEN 1
            WHEN b.temp_bytes >= 1024::numeric * 1024 * 1024
              OR b.temp_bytes_per_call >= 100::numeric * 1024 * 1024
                THEN 2
            WHEN b.temp_bytes >= 100::numeric * 1024 * 1024 OR b.calls >= 1000
                THEN 3
            ELSE 4
        END AS priority_number
    FROM base b
    CROSS JOIN totals t
),
ranked AS (
    SELECT
        s.*,
        row_number() OVER (
            ORDER BY s.priority_number, s.temp_bytes DESC, s.total_exec_time DESC
        ) AS investigation_rank
    FROM scored s
    WHERE s.temp_spill_pct >= (SELECT min_temp_spill_pct FROM params)
)
SELECT
    s.investigation_rank,
    'P' || s.priority_number AS priority,
    s.database_name,
    s.queryid,
    s.calls,
    clock_timestamp() - psi.stats_reset AS statistics_age,
    pg_size_pretty(s.temp_bytes::bigint) AS cumulative_temp_spill,
    pg_size_pretty(s.temp_bytes_per_call::bigint) AS temp_spill_per_call,
    round(s.temp_spill_pct::numeric, 2) AS temp_spill_pct,
    CASE
        WHEN s.temp_bytes_per_call >= 1024::numeric * 1024 * 1024 THEN 'VERY_LARGE_SPILL_PER_CALL'
        WHEN s.calls >= 1000 AND s.temp_bytes_per_call < 10::numeric * 1024 * 1024 THEN 'FREQUENT_SMALL_SPILL_CHURN'
        WHEN s.temp_blks_read > s.temp_blks_written THEN 'MULTI_PASS_TEMP_REREAD'
        WHEN s.calls <= 10 THEN 'FEW_SPILL_EVENTS'
        ELSE 'REPEATED_TEMP_SPILL'
    END AS spill_pattern,
    ('Run EXPLAIN (ANALYZE, BUFFERS, SETTINGS, VERBOSE) with representative binds and locate Sort/Hash nodes using Disk or multiple batches. Fix row estimates, joins, indexes, or batching first; change work_mem only for the validated query or transaction.' ||
        CASE
            WHEN clock_timestamp() - psi.stats_reset > interval '7 days'
                THEN ' Statistics are older than 7 days; compare before/after snapshots for current-load attribution.'
            ELSE ''
        END) AS recommended_action,
    regexp_replace(s.query, '\s+', ' ', 'g') AS complete_query_text
FROM ranked s
CROSS JOIN pg_stat_statements_info psi
ORDER BY s.investigation_rank
LIMIT 10;

-- SAMPLE_OUTPUT_BEGIN
-- rank | priority | database_name | queryid | calls | statistics_age | cumulative_temp_spill | temp_spill_per_call | temp_spill_pct | spill_pattern
-- 1    | P1       | appdb         | 987654  | 24    | 02:10:00       | 64 GB                 | 2731 MB             | 40.50          | VERY_LARGE_SPILL_PER_CALL
-- SAMPLE_OUTPUT_END
