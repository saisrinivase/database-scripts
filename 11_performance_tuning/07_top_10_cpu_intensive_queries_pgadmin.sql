/*
PostgreSQL DBA Script: Top 10 CPU and Page-Access Priorities (pgAdmin safe)
Purpose: Prioritize CPU investigation candidates using database time, cumulative page access, temp spill,
         and measured block-I/O evidence without presenting database time as exact host CPU.
Area: Performance Tuning
Compatibility: PostgreSQL 15+ with pg_stat_statements.
Usage: Run in pgAdmin Query Tool, psql, or another SQL client.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom for the compact result shape.
Notes: Read-only. This ranks CPU investigation candidates; it does not measure host CPU by query.

Optional session filters:
  SELECT set_config('pgdiag.min_workload_time_pct', '0', false);
  SELECT set_config('pgdiag.min_calls', '1', false);
  SELECT set_config('pgdiag.min_total_exec_ms', '0', false);
  SELECT set_config('pgdiag.max_rows', '10', false);
  SELECT set_config('pgdiag.query_filter', '', false);
  SELECT set_config('pgdiag.include_noise', 'off', false);

Measurement boundaries:
- total_exec_time is cumulative elapsed execution time, not host CPU time.
- PostgreSQL core does not retain historical wait-event time by query ID. Non-I/O elapsed time can
  still contain lock/LWLock waits, run-queue delay, extension work, and scheduler delay.
- cumulative_page_access = (shared_blks_hit + shared_blks_read) * block_size. It counts every page
  access, including repeated access to the same cached page. For example, 48 GB means the statement
  cumulatively accessed the equivalent of 48 GB of pages; it does not mean 48 GB of allocated RAM
  or 48 GB of physical disk I/O.
- High repeated page access can come from many calls, broad scans, or nested-loop repetitions. It can
  consume substantial CPU even when the pages are already cached.
- Counters cover the interval since pg_stat_statements_info.stats_reset. For an exact load-test
  interval, reset counters immediately before an approved test or store before/after snapshots.

Safe interpretation:
1. Use priority and the measured impact columns to choose what to investigate first.
2. Use primary_finding to understand the measured reason.
3. Perform recommended_action with representative bind values before applying a change.

The default result intentionally contains only the columns needed for incident triage. Database name
is included because the same query ID can occur in multiple databases as separate statistics entries.
*/

WITH params AS (
    SELECT
        coalesce(
            nullif(current_setting('pgdiag.min_workload_time_pct', true), '')::numeric,
            nullif(current_setting('pgdiag.min_cpu_pct', true), '')::numeric,
            0
        ) AS min_workload_time_pct,
        coalesce(nullif(current_setting('pgdiag.min_calls', true), '')::bigint, 1) AS min_calls,
        coalesce(nullif(current_setting('pgdiag.min_total_exec_ms', true), '')::numeric, 0) AS min_total_exec_ms,
        coalesce(nullif(current_setting('pgdiag.max_rows', true), '')::integer, 10) AS max_rows,
        coalesce(nullif(current_setting('pgdiag.query_filter', true), ''), '') AS query_filter,
        coalesce(nullif(current_setting('pgdiag.include_noise', true), '')::boolean, false) AS include_noise
),
settings AS (
    SELECT
        current_setting('track_io_timing') = 'on' AS io_timing_enabled,
        (SELECT stats_reset FROM pg_stat_statements_info) AS pgss_stats_reset,
        current_setting('block_size')::numeric AS block_size_bytes
),
base AS (
    SELECT
        s.*,
        coalesce(d.datname, s.dbid::text) AS database_name,
        coalesce((to_jsonb(s)->>'shared_blk_read_time')::numeric, (to_jsonb(s)->>'blk_read_time')::numeric, 0)
        + coalesce((to_jsonb(s)->>'shared_blk_write_time')::numeric, (to_jsonb(s)->>'blk_write_time')::numeric, 0)
        + coalesce((to_jsonb(s)->>'local_blk_read_time')::numeric, 0)
        + coalesce((to_jsonb(s)->>'local_blk_write_time')::numeric, 0)
        + coalesce((to_jsonb(s)->>'temp_blk_read_time')::numeric, 0)
        + coalesce((to_jsonb(s)->>'temp_blk_write_time')::numeric, 0) AS measured_block_io_ms,
        s.shared_blks_hit + s.shared_blks_read AS logical_shared_blocks,
        s.temp_blks_read + s.temp_blks_written AS temp_blocks,
        s.query ~* '^\s*select\s+[[:alnum:]_."$]+\s*\(' AND s.query !~* '\sfrom\s' AS single_function_call_shape,
        s.query ~* '\mDISTINCT\M' AS uses_distinct,
        s.query ~* 'order\s+by[^;]*(lower|trim)\s*\(' AS uses_expression_ordering
    FROM pg_stat_statements s
    CROSS JOIN params p
    LEFT JOIN pg_database d ON d.oid = s.dbid
    WHERE s.calls >= p.min_calls
      AND s.total_exec_time >= p.min_total_exec_ms
      AND (p.query_filter = '' OR s.query ILIKE '%' || p.query_filter || '%')
      AND (
          p.include_noise
          OR s.query !~* '^\s*(begin|commit|end|rollback|set|show|reset|discard|deallocate|analyze|vacuum|explain)\M'
      )
      AND (
          p.include_noise
          OR s.query !~* '(pg_catalog|information_schema|pg_stat_activity|pg_stat_statements|pg_show_all_settings|pg_settings|pg_temp\.|pg_backend_pid\(\)|pg_sleep\(|set_config\(|current_schema\(\)|session_user|dba_live\.)'
      )
),
totals AS (
    SELECT
        sum(total_exec_time) AS total_exec_time_ms,
        sum(logical_shared_blocks) AS total_logical_shared_blocks,
        sum(temp_blocks) AS total_temp_blocks,
        sum(CASE WHEN cfg.io_timing_enabled THEN greatest(b.total_exec_time - b.measured_block_io_ms, 0) END) AS total_non_io_elapsed_ms
    FROM base b
    CROSS JOIN settings cfg
),
scored AS (
    SELECT
        b.*,
        cfg.io_timing_enabled,
        cfg.pgss_stats_reset,
        cfg.block_size_bytes,
        100.0 * b.total_exec_time / NULLIF(t.total_exec_time_ms, 0) AS workload_time_pct,
        100.0 * b.logical_shared_blocks / NULLIF(t.total_logical_shared_blocks, 0) AS logical_blocks_pct,
        100.0 * b.temp_blocks / NULLIF(t.total_temp_blocks, 0) AS temp_blocks_pct,
        b.logical_shared_blocks::numeric / NULLIF(b.calls, 0) AS logical_blocks_per_call,
        b.temp_blocks::numeric / NULLIF(b.calls, 0) AS temp_blocks_per_call,
        b.rows::numeric / NULLIF(b.calls, 0) AS rows_per_call,
        b.stddev_exec_time / NULLIF(b.mean_exec_time, 0) AS runtime_cv,
        CASE
            WHEN cfg.io_timing_enabled THEN 100.0 * b.measured_block_io_ms / NULLIF(b.total_exec_time, 0)
        END AS measured_io_pct_of_exec,
        CASE
            WHEN cfg.io_timing_enabled THEN greatest(b.total_exec_time - b.measured_block_io_ms, 0)
        END AS non_io_elapsed_proxy_ms,
        CASE
            WHEN cfg.io_timing_enabled THEN 100.0 * greatest(b.total_exec_time - b.measured_block_io_ms, 0)
                / NULLIF(t.total_non_io_elapsed_ms, 0)
        END AS non_io_elapsed_share_pct
    FROM base b
    CROSS JOIN totals t
    CROSS JOIN settings cfg
),
prioritized AS (
    SELECT
        s.*,
        CASE
            WHEN (s.workload_time_pct >= 20 AND s.total_exec_time >= 1000)
              OR s.total_exec_time >= 60000
              OR s.temp_blocks * s.block_size_bytes >= 10::numeric * 1024 * 1024 * 1024
                THEN 1
            WHEN (s.workload_time_pct >= 5 AND s.total_exec_time >= 1000)
              OR s.mean_exec_time >= 1000
              OR (s.logical_blocks_pct >= 10 AND s.logical_shared_blocks >= 100000)
                THEN 2
            WHEN (s.workload_time_pct >= 2 AND s.total_exec_time >= 500)
              OR (s.calls >= 10000 AND s.total_exec_time >= 1000)
              OR (s.runtime_cv >= 1 AND s.calls >= 20 AND s.mean_exec_time >= 10)
                THEN 3
            ELSE 4
        END AS priority_number
    FROM scored s
    WHERE s.workload_time_pct >= (SELECT min_workload_time_pct FROM params)
),
ranked AS (
    SELECT
        p.*,
        row_number() OVER (
            ORDER BY p.priority_number, p.total_exec_time DESC, p.max_exec_time DESC
        ) AS investigation_rank
    FROM prioritized p
)
SELECT
    r.investigation_rank,
    'P' || r.priority_number AS priority,
    r.database_name,
    r.queryid,
    r.calls,
    round((r.total_exec_time / 1000)::numeric, 2) AS cumulative_database_time_s,
    round(r.workload_time_pct::numeric, 2) AS database_time_pct,
    pg_size_pretty((r.logical_shared_blocks * r.block_size_bytes)::bigint) AS cumulative_page_access,
    pg_size_pretty((r.temp_blocks * r.block_size_bytes)::bigint) AS cumulative_temp_spill,
    CASE
        WHEN r.temp_blocks * r.block_size_bytes >= 10::numeric * 1024 * 1024 * 1024
            THEN 'Large temp-file spill'
        WHEN r.temp_blocks > 0
            THEN 'Temp-file spill present'
        WHEN r.io_timing_enabled AND r.measured_io_pct_of_exec >= 50
            THEN 'Measured storage I/O dominates; not a CPU-first candidate'
        WHEN r.single_function_call_shape
            THEN 'Function wrapper; inspect nested SQL'
        WHEN r.logical_blocks_pct >= 10 AND r.logical_shared_blocks >= 100000
            THEN 'High repeated page access'
        WHEN r.calls >= 10000 AND r.total_exec_time >= 1000
            THEN 'High execution-frequency overhead'
        WHEN r.uses_distinct AND r.rows_per_call >= 100
            THEN 'Possible join multiplication or deduplication cost'
        WHEN r.uses_expression_ordering
            THEN 'Expression-based sort review'
        WHEN r.runtime_cv >= 1 AND r.calls >= 20 AND r.mean_exec_time >= 10
            THEN 'High runtime variation'
        WHEN NOT r.io_timing_enabled
            THEN 'High database time; CPU not confirmed'
        ELSE 'Non-I/O database-time CPU candidate'
    END AS primary_finding,
    (CASE
        WHEN r.temp_blocks > 0
            THEN 'Run EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, VERBOSE) with representative binds. Locate Sort/Hash nodes reporting Disk, excessive batches, rows removed, or actual rows far above estimates.'
        WHEN r.io_timing_enabled AND r.measured_io_pct_of_exec >= 50
            THEN 'This statement is measured-I/O dominant, so use the I/O diagnostic rather than treating it as CPU. Correlate storage latency and inspect EXPLAIN buffers.'
        WHEN r.single_function_call_shape
            THEN 'Enable pg_stat_statements.track=all for an approved test, identify the nested SQL, run 23_functions_dynamic_sql/05_sql_function_plan_cache_risk.sql, and explain the internal statement with representative binds.'
        WHEN r.logical_blocks_pct >= 10 AND r.logical_shared_blocks >= 100000
            THEN 'Run EXPLAIN (ANALYZE, BUFFERS, SETTINGS, VERBOSE). Find the node whose actual loops multiplied by page accesses drives repeated work; compare estimated and actual rows.'
        WHEN r.calls >= 10000 AND r.total_exec_time >= 1000
            THEN 'Check call rate and batching before changing the plan. Correlate this query ID with DBLoadCPU or host CPU during the same interval.'
        WHEN r.uses_distinct AND r.rows_per_call >= 100
            THEN 'Explain with representative binds and compare rows before and after DISTINCT. Verify whether one-to-many joins multiply rows and whether every selected column is required.'
        WHEN r.uses_expression_ordering
            THEN 'Explain with representative binds and inspect Sort Method, rows, memory, and upstream row count. Measure whether lower/trim ordering is a material portion of runtime.'
        WHEN r.runtime_cv >= 1
            THEN 'Capture plans for known fast and slow bind sets. Compare row estimates, join order, scan type, cache reads, and custom versus generic plan behavior.'
        ELSE 'Correlate this statistics window with CloudWatch CPUUtilization/DBLoadCPU, then capture EXPLAIN (ANALYZE, BUFFERS, SETTINGS, VERBOSE) for a representative execution.'
    END || CASE
        WHEN clock_timestamp() - r.pgss_stats_reset > interval '7 days'
            THEN ' Statistics are older than 7 days; use before/after snapshots or an approved reset for current-load attribution.'
        ELSE ''
    END) AS recommended_action,
    regexp_replace(r.query, '\s+', ' ', 'g') AS complete_query_text
FROM ranked r
WHERE r.investigation_rank <= (SELECT max_rows FROM params)
ORDER BY r.investigation_rank;

-- SAMPLE_OUTPUT_BEGIN
-- rank | priority | database_name | queryid | calls | cumulative_database_time_s | database_time_pct | cumulative_page_access | cumulative_temp_spill | primary_finding
-- 1    | P1       | appdb         | 123456  | 12000 | 812.40                     | 17.00             | 48 GB                  | 0 bytes               | High repeated page access
-- SAMPLE_OUTPUT_END
