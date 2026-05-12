/*
PostgreSQL DBA Script: Health Score Dashboard
Purpose: Show latest observer health score, status, metric summary, and open findings.
Area: Observer Agent Monitoring
Usage: Run after observer snapshots are captured to review current health posture.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Requires dba_observer repository from 01_create_observer_repository.sql.
*/
DROP TABLE IF EXISTS pg_temp.observer_health_score_result;
CREATE TEMP TABLE pg_temp.observer_health_score_result (
    snapshot_id bigint,
    captured_at timestamptz,
    database_name text,
    status text,
    health_score int,
    critical_findings bigint,
    warn_findings bigint,
    review_findings bigint,
    total_connections bigint,
    active_connections bigint,
    waiting_locks bigint,
    long_queries_over_5m bigint,
    cache_hit_pct numeric,
    max_slot_retained_wal text,
    max_replica_lag_seconds numeric,
    max_database_xid_age bigint,
    max_table_xid_age bigint,
    guidance text
);

DROP TABLE IF EXISTS pg_temp.observer_health_findings_result;
CREATE TEMP TABLE pg_temp.observer_health_findings_result (
    severity text,
    signal text,
    metric_name text,
    metric_value numeric,
    unit text,
    finding text,
    recommended_action text,
    next_script text
);

DO $$
BEGIN
    IF to_regclass('dba_observer.observer_snapshots') IS NOT NULL THEN
        EXECUTE $sql$
            WITH latest AS (
                SELECT *
                FROM dba_observer.observer_snapshots
                ORDER BY snapshot_id DESC
                LIMIT 1
            ),
            finding_summary AS (
                SELECT
                    snapshot_id,
                    count(*) FILTER (WHERE severity = 'CRITICAL') AS critical_findings,
                    count(*) FILTER (WHERE severity = 'WARN') AS warn_findings,
                    count(*) FILTER (WHERE severity = 'REVIEW') AS review_findings
                FROM dba_observer.observer_findings
                GROUP BY snapshot_id
            )
            INSERT INTO pg_temp.observer_health_score_result
            SELECT
                l.snapshot_id,
                l.captured_at,
                l.database_name,
                l.status,
                l.health_score,
                coalesce(fs.critical_findings, 0),
                coalesce(fs.warn_findings, 0),
                coalesce(fs.review_findings, 0),
                l.total_connections,
                l.active_connections,
                l.waiting_locks,
                l.long_queries_over_5m,
                l.cache_hit_pct,
                pg_size_pretty(coalesce(l.max_slot_retained_wal_bytes, 0)::bigint),
                l.max_replica_lag_seconds,
                l.max_database_xid_age,
                l.max_table_xid_age,
                NULL::text
            FROM latest l
            LEFT JOIN finding_summary fs ON fs.snapshot_id = l.snapshot_id
        $sql$;

        EXECUTE $sql$
            INSERT INTO pg_temp.observer_health_findings_result
            SELECT
                severity,
                signal,
                metric_name,
                metric_value,
                unit,
                finding,
                recommended_action,
                next_script
            FROM dba_observer.observer_findings
            WHERE snapshot_id = (SELECT max(snapshot_id) FROM dba_observer.observer_snapshots)
            ORDER BY
                CASE severity WHEN 'CRITICAL' THEN 1 WHEN 'WARN' THEN 2 WHEN 'REVIEW' THEN 3 ELSE 4 END,
                signal,
                metric_name
        $sql$;
    ELSE
        INSERT INTO pg_temp.observer_health_score_result (guidance)
        VALUES ('Observer repository is missing. Run 39_observer_agent_monitoring/01_create_observer_repository.sql, then 02_capture_observer_snapshot.sql.');
    END IF;
END;
$$;

SELECT *
FROM pg_temp.observer_health_score_result;

SELECT *
FROM pg_temp.observer_health_findings_result;

-- SAMPLE_OUTPUT_BEGIN
-- snapshot_id | captured_at             | database_name | status | health_score | critical_findings | warn_findings
-- ------------+-------------------------+---------------+--------+--------------+-------------------+--------------
--          42 | 2026-05-06 13:15:00-04 | appdb         | WARN   |           80 |                 0 |            2
--
-- severity | signal            | metric_name            | metric_value | finding
-- ---------+-------------------+------------------------+--------------+-----------------------------------------
-- WARN     | transaction_hygiene| transactions.over_15m  |            1 | Long transactions are present...
-- SAMPLE_OUTPUT_END
