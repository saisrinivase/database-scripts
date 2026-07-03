/*
PostgreSQL DBA Script: Wait Event Internals Live Map
Purpose: Map live wait events to internal subsystems and action hints for fast incident triage.
Area: Internals Deep Dive
Usage: Use when CPU looks idle but sessions are slow, blocked, waiting on IO, WAL, locks, extensions, or client/network.
Sample Output: Columns include wait_event_type, wait_event, waiting_sessions, subsystem_hint, action_hint.
Notes: Read-only diagnostic. Uses pg_stat_activity and works in pgAdmin and psql.
*/
WITH waits AS (
    SELECT
        coalesce(wait_event_type, 'CPU_or_not_waiting') AS wait_event_type,
        coalesce(wait_event, 'running_or_idle') AS wait_event,
        count(*) AS sessions,
        count(*) FILTER (WHERE state = 'active') AS active_sessions,
        max(now() - query_start) FILTER (WHERE query_start IS NOT NULL) AS max_query_age,
        max(now() - xact_start) FILTER (WHERE xact_start IS NOT NULL) AS max_xact_age
    FROM pg_stat_activity
    WHERE pid <> pg_backend_pid()
    GROUP BY coalesce(wait_event_type, 'CPU_or_not_waiting'), coalesce(wait_event, 'running_or_idle')
)
SELECT
    wait_event_type,
    wait_event,
    sessions AS waiting_sessions,
    active_sessions,
    max_query_age,
    max_xact_age,
    CASE
        WHEN wait_event_type = 'Lock' THEN 'lock_manager_or_heavyweight_locks'
        WHEN wait_event_type = 'LWLock' AND wait_event ILIKE '%buffer%' THEN 'shared_buffers_or_buffer_mapping'
        WHEN wait_event_type = 'LWLock' AND wait_event ILIKE '%wal%' THEN 'wal_insert_flush_or_sync'
        WHEN wait_event_type = 'IO' THEN 'storage_io_or_kernel_cache'
        WHEN wait_event_type = 'Client' THEN 'application_network_or_client_fetch'
        WHEN wait_event_type = 'Extension' THEN 'extension_code_or_foreign_access'
        WHEN wait_event_type = 'IPC' THEN 'parallel_query_background_worker_or_replication_ipc'
        WHEN wait_event_type = 'Timeout' THEN 'intentional_sleep_or_timeout'
        WHEN wait_event_type = 'CPU_or_not_waiting' THEN 'running_on_cpu_or_idle'
        ELSE 'postgres_internal_wait'
    END AS subsystem_hint,
    CASE
        WHEN wait_event_type = 'Lock' THEN 'Run blocking session drilldown, inspect transaction age, and resolve blocker before tuning SQL.'
        WHEN wait_event_type = 'LWLock' AND wait_event ILIKE '%buffer%' THEN 'Check buffer cache churn, hot blocks, indexes, and pg_stat_io read/write pressure.'
        WHEN wait_event_type = 'LWLock' AND wait_event ILIKE '%wal%' THEN 'Check WAL volume, synchronous commit, storage latency, wal_buffers_full, and checkpoint pressure.'
        WHEN wait_event_type = 'IO' THEN 'Correlate pg_stat_io, temp spills, checkpoint writes, storage IOPS, and query plans.'
        WHEN wait_event_type = 'Client' THEN 'Check application fetch size, connection pool behavior, network latency, and idle-in-transaction sessions.'
        WHEN wait_event_type = 'IPC' THEN 'Review parallel query, background worker saturation, replication, and leader/worker waits.'
        WHEN wait_event_type = 'CPU_or_not_waiting' THEN 'If active sessions are high, inspect top SQL CPU/time and OS CPU run queue.'
        ELSE 'Use wait_event plus backend_type/query text to route to the closest subsystem.'
    END AS action_hint
FROM waits
ORDER BY waiting_sessions DESC, active_sessions DESC, wait_event_type, wait_event;

-- SAMPLE_OUTPUT_BEGIN
-- wait_event_type | wait_event | waiting_sessions | subsystem_hint                 | action_hint
-- Lock            | relation   | 3                | lock_manager_or_heavyweight... | Run blocking session drilldown...
-- SAMPLE_OUTPUT_END
