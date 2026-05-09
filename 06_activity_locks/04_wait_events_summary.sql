/*
PostgreSQL DBA Script: Wait Events Summary
Purpose: Summarize wait events across sessions to spot dominant bottlenecks.
Area: Activity and Locks
Usage: Run repeatedly to compare shifting wait profiles.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH wait_summary AS (
    SELECT
        coalesce(wait_event_type, 'CPU/None') AS wait_event_type,
        coalesce(wait_event, 'CPU/None') AS wait_event,
        state,
        count(*) AS session_count
    FROM pg_stat_activity
    GROUP BY coalesce(wait_event_type, 'CPU/None'), coalesce(wait_event, 'CPU/None'), state
)
SELECT
    wait_event_type,
    wait_event,
    state,
    session_count,
    CASE
        WHEN wait_event_type = 'CPU/None' AND state = 'active'
            THEN 'Likely running on CPU or not currently waiting. Check top active SQL, execution plans, CPU saturation, and pg_stat_statements.'
        WHEN wait_event_type = 'CPU/None'
            THEN 'No wait event reported. If idle, this is usually normal; if many sessions accumulate, review pooling and application connection hygiene.'
        WHEN wait_event_type = 'Lock'
            THEN 'Find blockers with pg_blocking_pids(pid), inspect blocker query/xact age, then resolve the blocking transaction before tuning SQL.'
        WHEN wait_event_type = 'LWLock'
            THEN 'Lightweight lock contention. Correlate the specific wait_event with buffers, WAL, locks, extensions, or high concurrency hot spots.'
        WHEN wait_event_type = 'BufferPin'
            THEN 'A session is waiting for a buffer pin. Look for long cursors, idle-in-transaction sessions, or slow clients holding scanned buffers.'
        WHEN wait_event_type = 'IO'
            THEN 'Storage or file I/O wait. Check pg_stat_io on PG16+, cache hit ratio, temp spills, checkpoints, WAL pressure, and cloud/OS disk latency.'
        WHEN wait_event_type = 'Client'
            THEN 'Backend is waiting on the client. Check slow application fetches, network latency, large result sets, and idle-in-transaction behavior.'
        WHEN wait_event_type = 'Activity'
            THEN 'Background process idle/wait loop in many cases. Usually normal unless counts or timing correlate with lag, checkpoint, archive, or vacuum issues.'
        WHEN wait_event_type = 'Timeout'
            THEN 'Process is sleeping on a timer. Usually normal for background workers; correlate with autovacuum, checkpoint, or replication delay if symptoms exist.'
        WHEN wait_event_type = 'IPC'
            THEN 'Inter-process wait. Review parallel query, logical replication, background workers, and process coordination around the specific wait_event.'
        WHEN wait_event_type = 'Extension'
            THEN 'Extension-defined wait. Check the owning extension documentation, extension queries, and whether extension background workers are healthy.'
        ELSE 'Review PostgreSQL wait-event documentation for this event, then correlate with active SQL, locks, I/O, WAL, vacuum, and replication signals.'
    END AS resolution_guidance
FROM wait_summary
ORDER BY session_count DESC, wait_event_type, wait_event;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  wait_event_type |     wait_event      | state  | session_count | resolution_guidance
-- -----------------+---------------------+--------+---------------+------------------------------
--  Activity        | IoWorkerMain        |        |             3 | Background process idle/wait loop in many cases...
--  Client          | ClientRead          | idle   |             3 | Backend is waiting on the client...
--  Activity        | AutovacuumMain      |        |             1 | Background process idle/wait loop in many cases...
--  CPU/None        | CPU/None            | active |             1 | Likely running on CPU or not currently waiting...
-- (4 rows)
-- 
-- SAMPLE_OUTPUT_END
