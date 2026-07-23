/*
PostgreSQL DBA Script: AWS Compute Memory Serverless Pressure
Purpose: Deep-dive CPU, CPU-credit, ACU, free-memory, swap, and Aurora shared-memory alarms using PostgreSQL evidence.
Area: AWS RDS and Aurora PostgreSQL
Usage: Run during the same period as the CloudWatch alarm. CloudWatch remains authoritative for host and ACU values.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only except for a session-local pg_temp function. PostgreSQL 15+ and pgAdmin safe.
*/
WITH settings AS (
    SELECT
        current_setting('max_connections')::numeric AS max_connections,
        pg_size_bytes(current_setting('shared_buffers'))::numeric AS shared_buffers_bytes,
        pg_size_bytes(current_setting('work_mem'))::numeric AS work_mem_bytes,
        pg_size_bytes(current_setting('maintenance_work_mem'))::numeric AS maintenance_work_mem_bytes
),
activity AS (
    SELECT
        count(*) FILTER (WHERE backend_type = 'client backend')::numeric AS client_backends,
        count(*) FILTER (WHERE backend_type = 'client backend' AND state = 'active')::numeric AS active_backends,
        count(*) FILTER (
            WHERE backend_type = 'client backend'
              AND state = 'active'
              AND wait_event_type IS NULL
        )::numeric AS runnable_cpu_proxy,
        count(*) FILTER (WHERE wait_event_type IS NOT NULL)::numeric AS waiting_backends,
        count(*) FILTER (WHERE state = 'idle in transaction')::numeric AS idle_in_transaction,
        count(*) FILTER (WHERE backend_type = 'parallel worker')::numeric AS parallel_workers
    FROM pg_stat_activity
),
database_stats AS (
    SELECT
        coalesce(sum(temp_bytes), 0)::numeric AS temp_bytes,
        coalesce(sum(temp_files), 0)::numeric AS temp_files,
        min(stats_reset) AS oldest_database_stats_reset
    FROM pg_stat_database
)
SELECT
    'compute_memory_pressure' AS report_section,
    a.client_backends,
    a.active_backends,
    a.runnable_cpu_proxy,
    a.waiting_backends,
    a.idle_in_transaction,
    a.parallel_workers,
    round(100.0 * a.client_backends / NULLIF(s.max_connections, 0), 2) AS connection_utilization_pct,
    pg_size_pretty(s.shared_buffers_bytes::bigint) AS shared_buffers,
    pg_size_pretty(s.work_mem_bytes::bigint) AS work_mem_per_operation,
    pg_size_pretty(s.maintenance_work_mem_bytes::bigint) AS maintenance_work_mem,
    pg_size_pretty(d.temp_bytes::bigint) AS cumulative_temp_bytes,
    d.temp_files AS cumulative_temp_files,
    d.oldest_database_stats_reset,
    CASE
        WHEN a.runnable_cpu_proxy >= greatest(2, a.active_backends * 0.75) THEN 'CPU demand proxy is high: many active backends are not waiting.'
        WHEN a.waiting_backends > a.runnable_cpu_proxy THEN 'Wait pressure dominates the current snapshot; classify waits before scaling CPU.'
        WHEN a.client_backends >= s.max_connections * 0.80 THEN 'Connection concurrency can increase memory and scheduling pressure.'
        WHEN d.temp_bytes > 10::numeric * 1024 * 1024 * 1024 THEN 'Historical temp spill volume is high; compare interval deltas.'
        ELSE 'No dominant SQL-visible compute or memory proxy in this snapshot.'
    END AS diagnosis,
    'Use CloudWatch CPUUtilization/FreeableMemory/SwapUsage/ACU metrics for exact host values, then correlate the same time window.' AS aws_boundary
FROM activity a
CROSS JOIN settings s
CROSS JOIN database_stats d;

SELECT
    pid,
    usename,
    datname,
    application_name,
    client_addr,
    backend_type,
    state,
    clock_timestamp() - query_start AS query_age,
    wait_event_type,
    wait_event,
    regexp_replace(query, '\s+', ' ', 'g') AS complete_query_text,
    CASE
        WHEN state = 'active' AND wait_event_type IS NULL THEN 'RUNNABLE_CPU_CANDIDATE'
        WHEN wait_event_type IS NOT NULL THEN 'WAITING_NOT_CPU_PROOF'
        WHEN state = 'idle in transaction' THEN 'MEMORY_AND_TRANSACTION_HYGIENE_RISK'
        ELSE 'OTHER'
    END AS pressure_class
FROM pg_stat_activity
WHERE pid <> pg_backend_pid()
  AND (
      state = 'active'
      OR state = 'idle in transaction'
      OR backend_type IN ('parallel worker', 'autovacuum worker')
  )
ORDER BY
    CASE WHEN state = 'active' AND wait_event_type IS NULL THEN 1 ELSE 2 END,
    query_age DESC NULLS LAST;

CREATE OR REPLACE FUNCTION pg_temp.aws_compute_top_statements()
RETURNS TABLE (
    queryid bigint,
    calls bigint,
    total_exec_ms numeric,
    workload_time_pct numeric,
    temp_bytes numeric,
    shared_read_bytes numeric,
    wal_bytes numeric,
    complete_query_text text,
    diagnosis text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_statements') IS NULL
       AND to_regclass('public.pg_stat_statements') IS NULL THEN
        RETURN;
    END IF;

    RETURN QUERY EXECUTE $query$
        WITH ranked AS (
            SELECT
                s.queryid,
                s.calls,
                s.total_exec_time::numeric,
                100.0 * s.total_exec_time::numeric
                    / NULLIF(sum(s.total_exec_time::numeric) OVER (), 0) AS time_pct,
                (s.temp_blks_read + s.temp_blks_written)::numeric
                    * current_setting('block_size')::numeric AS temp_bytes,
                s.shared_blks_read::numeric
                    * current_setting('block_size')::numeric AS read_bytes,
                coalesce(s.wal_bytes, 0)::numeric AS wal_bytes,
                regexp_replace(s.query, '\s+', ' ', 'g') AS query_text
            FROM pg_stat_statements s
        )
        SELECT
            queryid,
            calls,
            round(total_exec_time, 2),
            round(time_pct, 2),
            temp_bytes,
            read_bytes,
            wal_bytes,
            query_text,
            CASE
                WHEN time_pct >= 20 THEN 'Statement consumes at least 20 percent of captured database execution time.'
                WHEN temp_bytes > 0 THEN 'Statement spills to temp and can contribute to memory/local-storage pressure.'
                WHEN read_bytes > 1024::numeric * 1024 * 1024 THEN 'Statement has substantial physical-read demand.'
                ELSE 'Review execution plan, call frequency, and incident-window change.'
            END
        FROM ranked
        ORDER BY time_pct DESC
        LIMIT 20
    $query$;
END;
$$;

SELECT *
FROM pg_temp.aws_compute_top_statements();

-- SAMPLE_OUTPUT_BEGIN
-- client_backends | active_backends | runnable_cpu_proxy | connection_utilization_pct | diagnosis
-- queryid | workload_time_pct | temp_bytes | shared_read_bytes | complete_query_text | diagnosis
-- SAMPLE_OUTPUT_END
