/*
PostgreSQL DBA Script: Top 10 CPU Investigation Priorities (pgAdmin safe)
Purpose: Prioritize statements for CPU investigation using measured pg_stat_statements evidence
         without presenting elapsed database time as exact host CPU consumption.
Area: Performance Tuning
Compatibility: PostgreSQL 15+ with pg_stat_statements.
Usage: Run in pgAdmin Query Tool, psql, or another SQL client.

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
1. Use priority and priority_reason to choose what to investigate first.
2. Use primary_finding and evidence_summary to understand the measured reason.
3. Perform recommended_next_test with representative bind values.
4. Apply possible_fix_after_validation only when the execution plan proves it is appropriate.
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
    CASE
        WHEN r.workload_time_pct >= 10
            THEN format('Consumes %s%% of captured application statement time.', round(r.workload_time_pct::numeric, 2))
        WHEN r.temp_blocks * r.block_size_bytes >= 10::numeric * 1024 * 1024 * 1024
            THEN format('Generated %s cumulative temp I/O.', pg_size_pretty((r.temp_blocks * r.block_size_bytes)::bigint))
        WHEN r.max_exec_time >= 60000
            THEN format('Observed maximum execution was %s seconds.', round((r.max_exec_time / 1000)::numeric, 2))
        WHEN r.logical_blocks_per_call >= 100000
            THEN format('Processes %s cached/read shared blocks per call.', round(r.logical_blocks_per_call, 0))
        WHEN r.mean_exec_time >= 1000
            THEN format('Average execution is %s ms.', round(r.mean_exec_time::numeric, 2))
        WHEN r.workload_time_pct >= 2
            THEN format('Consumes %s%% of captured application statement time.', round(r.workload_time_pct::numeric, 2))
        WHEN r.calls >= 10000
            THEN format('Executed %s times in the statistics window.', r.calls)
        WHEN r.runtime_cv >= 1
            THEN format('Runtime coefficient of variation is %s.', round(r.runtime_cv::numeric, 2))
        ELSE 'Lower measured impact than higher-priority rows in this report.'
    END AS priority_reason,
    coalesce(db.datname, r.dbid::text) AS database_name,
    coalesce(usr.rolname, r.userid::text) AS user_name,
    r.queryid,
    r.calls,
    round(r.workload_calls_pct::numeric, 2) AS workload_calls_pct,
    round(r.total_exec_time::numeric, 2) AS cumulative_exec_ms,
    round(r.workload_time_pct::numeric, 2) AS workload_exec_time_pct,
    round(r.mean_exec_time::numeric, 4) AS mean_exec_ms,
    round(r.min_exec_time::numeric, 4) AS min_exec_ms,
    round(r.max_exec_time::numeric, 2) AS max_exec_ms,
    round(r.stddev_exec_time::numeric, 2) AS stddev_exec_ms,
    round(r.runtime_cv::numeric, 2) AS runtime_cv,
    r.rows,
    round(r.rows_per_call, 2) AS rows_per_call,
    r.logical_shared_blocks,
    round(r.logical_blocks_per_call, 2) AS logical_blocks_per_call,
    round(r.logical_blocks_pct::numeric, 2) AS logical_blocks_pct,
    pg_size_pretty((r.logical_shared_blocks * r.block_size_bytes)::bigint) AS logical_page_access_byte_equivalent,
    round(100.0 * r.shared_blks_hit / NULLIF(r.logical_shared_blocks, 0), 2) AS shared_buffer_hit_pct,
    r.temp_blocks,
    round(r.temp_blocks_per_call, 2) AS temp_blocks_per_call,
    round(r.temp_blocks_pct::numeric, 2) AS temp_blocks_pct,
    pg_size_pretty((r.temp_blocks * r.block_size_bytes)::bigint) AS cumulative_temp_io,
    pg_size_pretty(coalesce(r.wal_bytes, 0)::bigint) AS cumulative_wal,
    round(r.measured_block_io_ms::numeric, 2) AS measured_block_io_ms,
    round((100.0 * r.measured_block_io_ms / NULLIF(r.total_exec_time, 0))::numeric, 2) AS measured_io_vs_exec_pct,
    round(r.non_io_elapsed_proxy_ms::numeric, 2) AS non_io_elapsed_proxy_ms,
    r.io_timing_enabled,
    r.plans,
    round((r.plans::numeric / NULLIF(r.calls, 0)), 4) AS plans_per_call,
    round(r.total_plan_time::numeric, 2) AS cumulative_plan_ms,
    r.planning_timing_enabled,
    r.jit_functions,
    r.parameter_marker_count,
    r.referenced_view_name_count,
    r.single_function_call_shape,
    r.uses_distinct,
    r.uses_expression_ordering,
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
    concat_ws(
        '; ',
        format('time_share=%s%%', round(r.workload_time_pct::numeric, 2)),
        format('calls=%s', r.calls),
        format('mean_ms=%s', round(r.mean_exec_time::numeric, 2)),
        format('max_ms=%s', round(r.max_exec_time::numeric, 2)),
        format('logical_blocks_per_call=%s', round(r.logical_blocks_per_call, 0)),
        format('rows_per_call=%s', round(r.rows_per_call, 2)),
        format('temp_io=%s', pg_size_pretty((r.temp_blocks * r.block_size_bytes)::bigint)),
        format('runtime_cv=%s', round(r.runtime_cv::numeric, 2))
    ) AS evidence_summary,
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
    END AS recommended_next_test,
    CASE
        WHEN r.temp_blocks > 0
            THEN 'Reduce rows before sort/hash by correcting joins, predicates, indexes, or estimates. Consider query/role-level work_mem only after the plan proves the spill operator and concurrency budget is safe.'
        WHEN r.single_function_call_shape
            THEN 'Tune the internal SQL first. On PostgreSQL 15-17, also verify SQL-function inlining or benchmark a semantically equivalent PL/pgSQL implementation; PostgreSQL 18 adds SQL-function plan caching.'
        WHEN r.uses_distinct AND r.rows_per_call >= 100
            THEN 'Correct join cardinality or use a semantics-preserving EXISTS/pre-aggregation approach if the plan proves row multiplication. Remove DISTINCT only after result-equivalence testing.'
        WHEN r.uses_expression_ordering
            THEN 'Reduce the input row set first. Consider a matching expression index only when the exact immutable expression, ordering, selectivity, and write cost are validated by the plan.'
        WHEN r.logical_blocks_per_call >= 100000
            THEN 'Correct the proven high-buffer plan node with selective join/filter indexes, rewritten predicates, extended statistics, or view simplification. Do not infer a missing index from this report alone.'
        WHEN r.calls >= 10000 AND r.mean_exec_time < 25
            THEN 'Reduce avoidable calls through application caching or batching when semantics permit; otherwise tune the proven internal plan.'
        ELSE 'Apply only the change supported by the captured plan and validate with before/after interval deltas under equivalent load.'
    END AS possible_fix_after_validation,
    CASE
        WHEN NOT r.io_timing_enabled THEN 'LOW_IO_SEPARATION_TRACK_IO_TIMING_OFF'
        WHEN r.measured_block_io_ms > r.total_exec_time * 0.50 THEN 'IO_DOMINANT_NOT_CPU_PROOF'
        WHEN r.single_function_call_shape THEN 'MEDIUM_OUTER_CALL_ONLY_INTERNAL_SQL_HIDDEN'
        ELSE 'MEDIUM_CPU_CANDIDATE_REQUIRES_HOST_CORRELATION'
    END AS attribution_confidence,
    r.pgss_stats_reset,
    clock_timestamp() - r.pgss_stats_reset AS statistics_window_age,
    regexp_replace(r.query, '\s+', ' ', 'g') AS complete_query_text
FROM ranked r
LEFT JOIN pg_roles usr ON usr.oid = r.userid
LEFT JOIN pg_database db ON db.oid = r.dbid
WHERE r.investigation_rank <= (SELECT max_rows FROM params)
ORDER BY r.investigation_rank;

-- SAMPLE_OUTPUT_BEGIN
-- rank | priority | priority_reason                   | primary_finding          | logical_blocks_per_call | recommended_next_test
-- 1    | P1       | Consumes 17.00% of captured...    | HIGH_CACHED_PAGE_CHURN   | 602459                  | Run EXPLAIN (ANALYZE...)
-- 2    | P1       | Generated 36 GB cumulative...    | LARGE_TEMP_SPILL         | 5375924                 | Run EXPLAIN (ANALYZE...)
-- SAMPLE_OUTPUT_END
