/*
PostgreSQL DBA Script: Generate Agent Summary
Purpose: Generate a concise observer-agent summary with health, likely issues, and next scripts.
Area: Observer Agent Monitoring
Usage: Run after active checks or scheduled snapshots to produce a DBA-readable incident summary.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Uses live metrics; if observer snapshots exist, includes latest stored snapshot context.
*/
WITH
live AS (
    SELECT
        now() AS observed_at,
        current_database() AS database_name,
        pg_is_in_recovery() AS is_standby,
        (SELECT count(*) FROM pg_stat_activity) AS total_connections,
        (SELECT count(*) FROM pg_stat_activity WHERE state = 'active') AS active_connections,
        (SELECT count(*) FROM pg_locks WHERE NOT granted) AS waiting_locks,
        (SELECT count(*) FROM pg_stat_activity WHERE xact_start IS NOT NULL AND now() - xact_start > interval '15 minutes') AS long_transactions,
        (SELECT count(*) FROM pg_stat_activity WHERE state = 'active' AND query_start IS NOT NULL AND now() - query_start > interval '5 minutes') AS long_queries,
        (SELECT failed_count FROM pg_stat_archiver) AS archive_failed_count,
        (SELECT coalesce(max(extract(epoch FROM replay_lag)), 0) FROM pg_stat_replication) AS max_replica_lag_seconds,
        (SELECT coalesce(max(age(datfrozenxid)), 0) FROM pg_database) AS max_database_xid_age
),
summary AS (
    SELECT 1 AS line_no,
           format('Observer summary for database %s at %s. Role: %s.',
                  database_name, observed_at, CASE WHEN is_standby THEN 'standby' ELSE 'primary/read-write' END) AS summary_line
    FROM live
    UNION ALL
    SELECT 2,
           format('Current load: %s total connections, %s active, %s waiting locks.',
                  total_connections, active_connections, waiting_locks)
    FROM live
    UNION ALL
    SELECT 3,
           CASE
             WHEN waiting_locks > 0 THEN 'Immediate concern: blocking locks are present. Run 06_activity_locks/02_blocking_and_blocked_sessions.sql.'
             WHEN long_transactions > 0 THEN 'Immediate concern: long transactions are present. Run 06_activity_locks/03_long_running_transactions.sql.'
             WHEN long_queries > 0 THEN 'Immediate concern: long active queries are present. Run 18_long_queries_full_scans/01_active_long_queries.sql.'
             WHEN archive_failed_count > 0 THEN 'Immediate concern: WAL archiver failures are present. Run 13_io_wal_checkpoints/04_wal_archiver_health.sql.'
             WHEN max_replica_lag_seconds >= 60 THEN 'Immediate concern: replica lag is above threshold. Run 38_observability_360/09_replication_and_slot_dashboard.sql.'
             WHEN max_database_xid_age >= 1000000000 THEN 'Immediate concern: XID age is high. Run 16_internals_deep_dive/01_database_xid_multixact_age.sql.'
             ELSE 'No immediate SQL-visible critical issue detected by the observer summary.'
           END
    FROM live
    UNION ALL
    SELECT 4,
           'Next best route: run 39_observer_agent_monitoring/04_active_incident_detector.sql, then 06_top_root_cause_action_queue.sql.'
)
SELECT line_no, summary_line
FROM summary
ORDER BY line_no;

DROP TABLE IF EXISTS pg_temp.observer_agent_summary_snapshot_result;
CREATE TEMP TABLE pg_temp.observer_agent_summary_snapshot_result (
    section text,
    snapshot_id bigint,
    captured_at timestamptz,
    status text,
    health_score int,
    findings_count int,
    repository_guidance text
);

DO $$
BEGIN
    IF to_regclass('dba_observer.observer_snapshots') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO pg_temp.observer_agent_summary_snapshot_result
            SELECT
                'latest_stored_snapshot',
                snapshot_id,
                captured_at,
                status,
                health_score,
                jsonb_array_length(findings),
                NULL::text
            FROM dba_observer.observer_snapshots
            ORDER BY snapshot_id DESC
            LIMIT 1
        $sql$;
    ELSE
        INSERT INTO pg_temp.observer_agent_summary_snapshot_result (repository_guidance)
        VALUES ('observer repository not found; run 01_create_observer_repository.sql and 02_capture_observer_snapshot.sql for stored history.');
    END IF;
END;
$$;

SELECT *
FROM pg_temp.observer_agent_summary_snapshot_result;

-- SAMPLE_OUTPUT_BEGIN
-- line_no | summary_line
-- --------+--------------------------------------------------------------------------------
--       1 | Observer summary for database appdb at 2026-05-06 13:15:00-04. Role: primary/read-write.
--       2 | Current load: 42 total connections, 8 active, 0 waiting locks.
--       3 | No immediate SQL-visible critical issue detected by the observer summary.
-- SAMPLE_OUTPUT_END
