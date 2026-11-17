/*
PostgreSQL DBA Script: Identify Active CPU Process Candidates (pgAdmin safe)
Purpose: Identify active PostgreSQL backend processes and SQL that may be consuming CPU right now.
Area: Live Test Monitoring
Compatibility: PostgreSQL 15+ including self-managed PostgreSQL, Amazon RDS for PostgreSQL, and Aurora PostgreSQL.
Usage: Run repeatedly in pgAdmin Query Tool while CPU pressure is occurring.
       Optional minimum active runtime in seconds:
       SELECT set_config('pgdiag.min_active_seconds', '0.5', false);
Sample Output: See SAMPLE_OUTPUT_BEGIN below.
Notes: Read-only and extension-free. PostgreSQL does not expose exact per-query OS CPU percentage.
       An active backend with no wait event is a CPU or scheduler run-queue candidate, not proof of CPU use.
       Users normally need pg_read_all_stats, pg_monitor, rds_superuser, or equivalent visibility to see
       complete SQL text and details for sessions owned by other users.
*/

WITH params AS (
    SELECT coalesce(
        nullif(current_setting('pgdiag.min_active_seconds', true), '')::numeric,
        1
    ) AS min_active_seconds
),
active_processes AS (
    SELECT
        a.*,
        extract(epoch FROM (clock_timestamp() - a.query_start))::numeric AS runtime_seconds,
        pg_blocking_pids(a.pid) AS blocking_pids
    FROM pg_stat_activity a
    CROSS JOIN params p
    WHERE a.pid <> pg_backend_pid()
      AND a.state = 'active'
      AND a.backend_type IN ('client backend', 'parallel worker')
      AND a.query_start IS NOT NULL
      AND extract(epoch FROM (clock_timestamp() - a.query_start)) >= p.min_active_seconds
)
SELECT
    CASE
        WHEN cardinality(a.blocking_pids) > 0 THEN 'P2'
        WHEN a.wait_event_type IS NULL AND a.runtime_seconds >= 1 THEN 'P1'
        WHEN a.wait_event_type IS NULL THEN 'P2'
        ELSE 'P3'
    END AS investigation_priority,
    a.pid AS backend_pid,
    coalesce(a.leader_pid, a.pid) AS process_group_leader_pid,
    CASE WHEN a.leader_pid IS NULL THEN 'leader_or_serial_backend' ELSE 'parallel_worker' END AS process_role,
    a.datname AS database_name,
    a.usename AS user_name,
    a.application_name,
    a.client_addr,
    round(a.runtime_seconds, 3) AS active_runtime_seconds,
    a.wait_event_type,
    a.wait_event,
    a.blocking_pids,
    a.query_id,
    CASE
        WHEN cardinality(a.blocking_pids) > 0 THEN 'Blocked; not currently a CPU-first candidate'
        WHEN a.wait_event_type IS NULL THEN 'Active with no reported wait; CPU or run-queue candidate'
        ELSE 'Active but waiting; investigate the reported wait first'
    END AS cpu_evidence,
    CASE
        WHEN cardinality(a.blocking_pids) > 0
            THEN 'Inspect the blocking PID and its transaction before investigating CPU.'
        WHEN a.wait_event_type IS NULL
            THEN 'Correlate this PID and timestamp with host CPU or AWS DBLoadCPU, then validate the SQL with EXPLAIN (ANALYZE, BUFFERS, WAL, SETTINGS, VERBOSE) using representative binds.'
        ELSE 'Route diagnosis to the reported wait_event_type and wait_event; elapsed time is not CPU time.'
    END AS next_action,
    regexp_replace(a.query, '\s+', ' ', 'g') AS complete_query_text
FROM active_processes a
ORDER BY
    CASE
        WHEN cardinality(a.blocking_pids) = 0 AND a.wait_event_type IS NULL THEN 1
        WHEN cardinality(a.blocking_pids) > 0 THEN 2
        ELSE 3
    END,
    a.runtime_seconds DESC,
    a.pid;

-- SAMPLE_OUTPUT_BEGIN
-- investigation_priority | backend_pid | process_group_leader_pid | process_role             | database_name | application_name          | active_runtime_seconds | wait_event_type | query_id             | cpu_evidence
-- P1                     | 93836       | 93836                    | leader_or_serial_backend | postgres      | pgdiag_cpu_pressure_lab   | 5.801                  |                 | 849216942406289872   | Active with no reported wait; CPU or run-queue candidate
-- SAMPLE_OUTPUT_END
