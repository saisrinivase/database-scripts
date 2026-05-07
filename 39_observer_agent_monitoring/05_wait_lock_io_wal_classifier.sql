/*
PostgreSQL DBA Script: Wait Lock IO WAL Classifier
Purpose: Classify current pressure into wait, lock, I/O, temp, WAL, archive, and replication domains.
Area: Observer Agent Monitoring
Usage: Run after the active incident detector to understand which pressure domain is dominant.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Classification is heuristic and should route you to the next diagnostic script.
*/
WITH
waits AS (
    SELECT
        coalesce(wait_event_type, 'not_waiting') AS wait_event_type,
        coalesce(wait_event, 'not_waiting') AS wait_event,
        count(*) AS sessions
    FROM pg_stat_activity
    GROUP BY coalesce(wait_event_type, 'not_waiting'), coalesce(wait_event, 'not_waiting')
),
wait_rollup AS (
    SELECT
        count(*) FILTER (WHERE wait_event_type = 'Lock')::numeric AS lock_wait_sessions,
        count(*) FILTER (WHERE wait_event_type = 'IO')::numeric AS io_wait_sessions,
        count(*) FILTER (WHERE wait_event_type = 'LWLock')::numeric AS lwlock_wait_sessions,
        count(*) FILTER (WHERE wait_event_type = 'Client')::numeric AS client_wait_sessions,
        count(*) FILTER (WHERE wait_event_type <> 'not_waiting')::numeric AS total_wait_sessions
    FROM pg_stat_activity
),
locks AS (
    SELECT count(*) FILTER (WHERE NOT granted)::numeric AS waiting_locks
    FROM pg_locks
),
db AS (
    SELECT
        coalesce(sum(temp_bytes), 0)::numeric AS temp_bytes,
        coalesce(sum(blk_read_time), 0)::numeric AS blk_read_time,
        coalesce(sum(blk_write_time), 0)::numeric AS blk_write_time
    FROM pg_stat_database
    WHERE datname NOT IN ('template0', 'template1')
),
wal AS (
    SELECT wal_bytes::numeric, wal_buffers_full::numeric
    FROM pg_stat_wal
),
archiver AS (
    SELECT failed_count::numeric AS archive_failed_count
    FROM pg_stat_archiver
),
replication AS (
    SELECT coalesce(max(extract(epoch FROM replay_lag)), 0)::numeric AS max_replica_lag_seconds
    FROM pg_stat_replication
)
SELECT *
FROM (
    SELECT 'lock_pressure' AS pressure_domain,
           CASE WHEN l.waiting_locks > 0 OR w.lock_wait_sessions > 0 THEN 'ACTIVE' ELSE 'quiet' END AS signal_state,
           greatest(l.waiting_locks, w.lock_wait_sessions) AS signal_value,
           'count' AS unit,
           'Lock waits/blocking can freeze application throughput even when CPU is low.' AS interpretation,
           '06_activity_locks/02_blocking_and_blocked_sessions.sql' AS next_script
    FROM wait_rollup w CROSS JOIN locks l
    UNION ALL
    SELECT 'io_pressure',
           CASE WHEN w.io_wait_sessions > 0 OR d.blk_read_time + d.blk_write_time > 0 THEN 'REVIEW' ELSE 'quiet' END,
           w.io_wait_sessions,
           'sessions',
           'IO waits or cumulative block timing point toward storage/query access pressure.',
           '13_io_wal_checkpoints/01_database_io_profile.sql'
    FROM wait_rollup w CROSS JOIN db d
    UNION ALL
    SELECT 'temp_spill_pressure',
           CASE WHEN d.temp_bytes > 0 THEN 'REVIEW' ELSE 'quiet' END,
           d.temp_bytes,
           'bytes_since_reset',
           'Temp bytes indicate sort/hash spill pressure or temp-heavy workloads.',
           '11_performance_tuning/03_temp_file_heavy_queries.sql'
    FROM db d
    UNION ALL
    SELECT 'wal_pressure',
           CASE WHEN wal_buffers_full > 0 THEN 'REVIEW' ELSE 'quiet' END,
           wal_buffers_full,
           'count_since_reset',
           'WAL buffers full can indicate WAL write/checkpoint pressure.',
           '38_observability_360/07_wal_checkpoint_archiver_dashboard.sql'
    FROM wal
    UNION ALL
    SELECT 'archive_pressure',
           CASE WHEN archive_failed_count > 0 THEN 'ACTIVE' ELSE 'quiet' END,
           archive_failed_count,
           'count_since_reset',
           'Archive failures create PITR risk and can coincide with WAL accumulation.',
           '30_backup_restore_pitr_dr/02_wal_archiving_gap_and_lag.sql'
    FROM archiver
    UNION ALL
    SELECT 'replication_pressure',
           CASE WHEN max_replica_lag_seconds >= 60 THEN 'ACTIVE' ELSE 'quiet' END,
           max_replica_lag_seconds,
           'seconds',
           'Replica lag can indicate apply, network, IO, or downstream workload pressure.',
           '38_observability_360/09_replication_and_slot_dashboard.sql'
    FROM replication
    UNION ALL
    SELECT 'client_wait_pressure',
           CASE WHEN client_wait_sessions > 0 THEN 'INFO' ELSE 'quiet' END,
           client_wait_sessions,
           'sessions',
           'Client waits may indicate slow clients, network behavior, or idle result consumption.',
           '14_connection_workload/01_connections_by_user_app_db.sql'
    FROM wait_rollup
) classified
ORDER BY
    CASE signal_state WHEN 'ACTIVE' THEN 1 WHEN 'REVIEW' THEN 2 WHEN 'INFO' THEN 3 ELSE 4 END,
    pressure_domain;

WITH waits AS (
    SELECT
        coalesce(wait_event_type, 'not_waiting') AS wait_event_type,
        coalesce(wait_event, 'not_waiting') AS wait_event,
        count(*) AS sessions
    FROM pg_stat_activity
    GROUP BY coalesce(wait_event_type, 'not_waiting'), coalesce(wait_event, 'not_waiting')
)
SELECT
    wait_event_type,
    wait_event,
    sessions
FROM waits
ORDER BY sessions DESC, wait_event_type, wait_event
LIMIT 20;

-- SAMPLE_OUTPUT_BEGIN
-- pressure_domain     | signal_state | signal_value | unit              | interpretation
-- --------------------+--------------+--------------+-------------------+-----------------------------------------------
-- lock_pressure       | ACTIVE       |            2 | count             | Lock waits/blocking can freeze...
-- temp_spill_pressure | REVIEW       |   1073741824 | bytes_since_reset | Temp bytes indicate sort/hash spill...
-- SAMPLE_OUTPUT_END
