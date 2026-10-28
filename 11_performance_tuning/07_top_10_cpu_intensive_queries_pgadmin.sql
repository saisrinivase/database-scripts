/*
PostgreSQL DBA Script: Top 10 CPU Investigation Priorities (pgAdmin safe)
Purpose: Prioritize statements for CPU investigation using measured pg_stat_statements evidence
         without presenting elapsed database time as exact host CPU consumption.
Area: Performance Tuning
Compatibility: PostgreSQL 15+ with pg_stat_statements.
Usage: Run in pgAdmin Query Tool, psql, or another SQL client.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom for the compact result shape.
Notes: Read-only. This ranks CPU investigation candidates; it does not measure host CPU by query.

Optional session filters:
  SELECT set_config('pgdiag.min_workload_time_pct', '0', false);
  SELECT set_config('pgdiag.min_calls', '1', false);
  SELECT set_config('pgdiag.max_rows', '10', false);
  SELECT set_config('pgdiag.query_filter', '', false);
  SELECT set_config('pgdiag.include_noise', 'off', false);

Measurement boundaries:
- total_exec_time is cumulative elapsed execution time, not host CPU time.
- PostgreSQL core does not retain historical wait-event time by query ID. Non-I/O elapsed time can
  still contain lock/LWLock waits, run-queue delay, extension work, and scheduler delay.
- shared_blks_hit measures cached 8 kB page accesses. A high hit ratio avoids storage reads but a
  very large number of hits can still represent substantial scan, join, aggregation, and CPU work.
- Counters cover the interval since pg_stat_statements_info.stats_reset. For an exact load-test
  interval, reset counters immediately before an approved test or store before/after snapshots.

Safe interpretation:
1. Use priority and the measured impact columns to choose what to investigate first.
2. Use primary_finding to understand the measured reason.
3. Perform recommended_action with representative bind values before applying a change.

The default result intentionally contains only the columns needed for incident triage.
*/

WITH params AS (
    SELECT
        coalesce(
            nullif(current_setting('pgdiag.min_workload_time_pct', true), '')::numeric,
            nullif(current_setting('pgdiag.min_cpu_pct', true), '')::numeric,
            0
        ) AS min_workload_time_pct,
        coalesce(nullif(current_setting('pgdiag.min_calls', true), '')::bigint, 1) AS min_calls,
        coalesce(nullif(current_setting('pgdiag.max_rows', true), '')::integer, 10) AS max_rows,
        coalesce(nullif(current_setting('pgdiag.query_filter', true), ''), '') AS query_filter,
        coalesce(nullif(current_setting('pgdiag.include_noise', true), '')::boolean, false) AS include_noise
),
settings AS (
    SELECT
        current_setting('track_io_timing') = 'on' AS io_timing_enabled,
        current_setting('pg_stat_statements.track_planning', true) = 'on' AS planning_timing_enabled,
        (SELECT stats_reset FROM pg_stat_statements_info) AS pgss_stats_reset,
        current_setting('block_size')::numeric AS block_size_bytes
),
base AS (
    SELECT
        s.*,
        coalesce(s.shared_blk_read_time, 0)
        + coalesce(s.shared_blk_write_time, 0)
        + coalesce(s.local_blk_read_time, 0)
        + coalesce(s.local_blk_write_time, 0)
        + coalesce(s.temp_blk_read_time, 0)
        + coalesce(s.temp_blk_write_time, 0) AS measured_block_io_ms,
        s.shared_blks_hit + s.shared_blks_read AS logical_shared_blocks,
        s.temp_blks_read + s.temp_blks_written AS temp_blocks,
        regexp_count(s.query, '\$[0-9]+') AS parameter_marker_count,
        regexp_count(s.query, '\.vw_', 1, 'i') AS referenced_view_name_count,
        s.query ~* '^\s*select\s+[[:alnum:]_."$]+\s*\(' AND s.query !~* '\sfrom\s' AS single_function_call_shape,
        s.query ~* '\mDISTINCT\M' AS uses_distinct,
        s.query ~* 'order\s+by[^;]*(lower|trim)\s*\(' AS uses_expression_ordering
    FROM pg_stat_statements s
    CROSS JOIN params p
    WHERE s.calls >= p.min_calls
      AND (p.query_filter = '' OR s.query ILIKE '%' || p.query_filter || '%')
      AND (
          p.include_noise
          OR s.query !~* '^\s*(begin|commit|end|rollback|set|show|reset|discard|deallocate|analyze|vacuum|explain)\M'
      )
      AND (
          p.include_noise
          OR s.query !~* '(pg_catalog|information_schema|pg_stat_activity|pg_stat_statements|pg_show_all_settings|pg_settings|pg_backend_pid\(\)|pg_sleep\(|set_config\(|current_schema\(\)|session_user|dba_live\.)'
      )
),
totals AS (
    SELECT
        sum(total_exec_time) AS total_exec_time_ms,
        sum(calls) AS total_calls,
        sum(logical_shared_blocks) AS total_logical_shared_blocks,
        sum(temp_blocks) AS total_temp_blocks
    FROM base
),
scored AS (
    SELECT
        b.*,
        cfg.io_timing_enabled,
        cfg.planning_timing_enabled,
        cfg.pgss_stats_reset,
        cfg.block_size_bytes,
        100.0 * b.total_exec_time / NULLIF(t.total_exec_time_ms, 0) AS workload_time_pct,
        100.0 * b.calls / NULLIF(t.total_calls, 0) AS workload_calls_pct,
        100.0 * b.logical_shared_blocks / NULLIF(t.total_logical_shared_blocks, 0) AS logical_blocks_pct,
        100.0 * b.temp_blocks / NULLIF(t.total_temp_blocks, 0) AS temp_blocks_pct,
        b.logical_shared_blocks::numeric / NULLIF(b.calls, 0) AS logical_blocks_per_call,
        b.temp_blocks::numeric / NULLIF(b.calls, 0) AS temp_blocks_per_call,
        b.rows::numeric / NULLIF(b.calls, 0) AS rows_per_call,
        b.stddev_exec_time / NULLIF(b.mean_exec_time, 0) AS runtime_cv,
        CASE
            WHEN cfg.io_timing_enabled THEN greatest(b.total_exec_time - b.measured_block_io_ms, 0)
        END AS non_io_elapsed_proxy_ms
    FROM base b
    CROSS JOIN totals t
    CROSS JOIN settings cfg
),
prioritized AS (
    SELECT
        s.*,
        CASE
            WHEN s.workload_time_pct >= 10
              OR s.max_exec_time >= 60000
              OR s.temp_blocks * s.block_size_bytes >= 10::numeric * 1024 * 1024 * 1024
                THEN 1
            WHEN s.workload_time_pct >= 5
              OR s.mean_exec_time >= 1000
              OR s.logical_blocks_per_call >= 100000
                THEN 2
            WHEN s.workload_time_pct >= 2
              OR s.calls >= 10000
              OR s.runtime_cv >= 1
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
    r.queryid,
    r.calls,
    round(r.workload_time_pct::numeric, 2) AS workload_exec_time_pct,
    round(r.mean_exec_time::numeric, 2) AS mean_exec_ms,
    round(r.max_exec_time::numeric, 2) AS max_exec_ms,
    round(r.logical_blocks_per_call, 0) AS logical_blocks_per_call,
    pg_size_pretty((r.temp_blocks * r.block_size_bytes)::bigint) AS cumulative_temp_io,
    CASE
        WHEN r.temp_blocks * r.block_size_bytes >= 10::numeric * 1024 * 1024 * 1024
            THEN 'LARGE_TEMP_SPILL'
        WHEN r.temp_blocks > 0
            THEN 'TEMP_SPILL_PRESENT'
        WHEN r.single_function_call_shape
            THEN 'FUNCTION_WRAPPER_REQUIRES_NESTED_SQL'
        WHEN r.logical_blocks_per_call >= 100000 AND r.shared_blks_hit > r.shared_blks_read
            THEN 'HIGH_CACHED_PAGE_CHURN'
        WHEN r.uses_distinct AND r.rows_per_call >= 100
            THEN 'JOIN_MULTIPLICATION_OR_DEDUP_REVIEW'
        WHEN r.uses_expression_ordering
            THEN 'EXPRESSION_SORT_REVIEW'
        WHEN r.runtime_cv >= 1
            THEN 'HIGH_RUNTIME_VARIANCE'
        WHEN r.calls >= 10000 AND r.mean_exec_time < 25
            THEN 'HIGH_FREQUENCY_OVERHEAD'
        ELSE 'HIGH_DATABASE_TIME_REQUIRES_PLAN'
    END AS primary_finding,
    CASE
        WHEN r.temp_blocks > 0
            THEN 'Run EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, VERBOSE) with representative binds. Locate Sort/Hash nodes reporting Disk, excessive batches, rows removed, or actual rows far above estimates.'
        WHEN r.single_function_call_shape
            THEN 'Enable pg_stat_statements.track=all for an approved test, identify the nested SQL, run 23_functions_dynamic_sql/05_sql_function_plan_cache_risk.sql, and explain the internal statement with representative binds.'
        WHEN r.logical_blocks_per_call >= 100000
            THEN 'Run EXPLAIN (ANALYZE, BUFFERS, SETTINGS, VERBOSE) with representative binds. Find the node whose actual loops multiplied by buffer hits produces the page churn; compare estimated and actual rows at that node.'
        WHEN r.uses_distinct AND r.rows_per_call >= 100
            THEN 'Explain with representative binds and compare rows before and after DISTINCT. Verify whether one-to-many joins multiply rows and whether every selected column is required.'
        WHEN r.uses_expression_ordering
            THEN 'Explain with representative binds and inspect Sort Method, rows, memory, and upstream row count. Measure whether lower/trim ordering is a material portion of runtime.'
        WHEN r.runtime_cv >= 1
            THEN 'Capture plans for known fast and slow bind sets. Compare row estimates, join order, scan type, cache reads, and custom versus generic plan behavior.'
        ELSE 'Correlate this statistics window with CloudWatch CPUUtilization/DBLoadCPU, then capture EXPLAIN (ANALYZE, BUFFERS, SETTINGS, VERBOSE) for a representative execution.'
    END AS recommended_action,
    regexp_replace(r.query, '\s+', ' ', 'g') AS complete_query_text
FROM ranked r
WHERE r.investigation_rank <= (SELECT max_rows FROM params)
ORDER BY r.investigation_rank;

-- SAMPLE_OUTPUT_BEGIN
-- rank | priority | queryid | time_pct | mean_ms | logical_blocks_per_call | temp_io | primary_finding        | recommended_action
-- 1    | P1       | 123456  | 17.00    | 738.36  | 602465                  | 0 bytes | HIGH_CACHED_PAGE_CHURN | Run EXPLAIN (ANALYZE...)
-- SAMPLE_OUTPUT_END
