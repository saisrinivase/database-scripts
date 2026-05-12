/*
PostgreSQL DBA Script: Baseline Deviation Report
Purpose: Compare the latest observer snapshot with the previous snapshot to highlight fast-changing metrics.
Area: Observer Agent Monitoring
Usage: Run after at least two observer captures; schedule snapshots first for meaningful deltas.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Requires dba_observer repository and at least two snapshots.
*/
DROP TABLE IF EXISTS pg_temp.observer_baseline_deviation_result;
CREATE TEMP TABLE pg_temp.observer_baseline_deviation_result (
    latest_snapshot_id bigint,
    latest_captured_at timestamptz,
    previous_snapshot_id bigint,
    previous_captured_at timestamptz,
    metric_name text,
    previous_value numeric,
    latest_value numeric,
    delta_value numeric,
    delta_pct numeric,
    unit text,
    deviation_signal text,
    guidance text
);

DO $$
BEGIN
    IF to_regclass('dba_observer.observer_snapshots') IS NOT NULL THEN
        EXECUTE $sql$
            WITH ranked AS (
                SELECT *, row_number() OVER (ORDER BY snapshot_id DESC) AS rn
                FROM dba_observer.observer_snapshots
            ),
            latest AS (
                SELECT * FROM ranked WHERE rn = 1
            ),
            previous AS (
                SELECT * FROM ranked WHERE rn = 2
            ),
            metric_pairs AS (
                SELECT
                    l.snapshot_id AS latest_snapshot_id,
                    l.captured_at AS latest_captured_at,
                    p.snapshot_id AS previous_snapshot_id,
                    p.captured_at AS previous_captured_at,
                    v.metric_name,
                    v.latest_value,
                    v.previous_value,
                    v.unit
                FROM latest l
                CROSS JOIN previous p
                CROSS JOIN LATERAL (VALUES
                    ('health_score', l.health_score::numeric, p.health_score::numeric, 'score'),
                    ('total_connections', l.total_connections::numeric, p.total_connections::numeric, 'count'),
                    ('active_connections', l.active_connections::numeric, p.active_connections::numeric, 'count'),
                    ('waiting_locks', l.waiting_locks::numeric, p.waiting_locks::numeric, 'count'),
                    ('long_queries_over_5m', l.long_queries_over_5m::numeric, p.long_queries_over_5m::numeric, 'count'),
                    ('temp_bytes', l.temp_bytes, p.temp_bytes, 'bytes'),
                    ('wal_bytes', l.wal_bytes, p.wal_bytes, 'bytes'),
                    ('wal_buffers_full', l.wal_buffers_full, p.wal_buffers_full, 'count'),
                    ('max_slot_retained_wal_bytes', l.max_slot_retained_wal_bytes, p.max_slot_retained_wal_bytes, 'bytes'),
                    ('max_replica_lag_seconds', l.max_replica_lag_seconds, p.max_replica_lag_seconds, 'seconds'),
                    ('max_database_xid_age', l.max_database_xid_age, p.max_database_xid_age, 'xids'),
                    ('max_table_xid_age', l.max_table_xid_age, p.max_table_xid_age, 'xids'),
                    ('autovacuum_backlog_tables', l.autovacuum_backlog_tables::numeric, p.autovacuum_backlog_tables::numeric, 'count')
                ) AS v(metric_name, latest_value, previous_value, unit)
            )
            INSERT INTO pg_temp.observer_baseline_deviation_result
            SELECT
                latest_snapshot_id,
                latest_captured_at,
                previous_snapshot_id,
                previous_captured_at,
                metric_name,
                previous_value,
                latest_value,
                latest_value - previous_value,
                round(100.0 * (latest_value - previous_value) / NULLIF(abs(previous_value), 0), 2),
                unit,
                CASE
                    WHEN metric_name = 'health_score' AND latest_value < previous_value THEN 'HEALTH_SCORE_DROPPED'
                    WHEN metric_name <> 'health_score' AND latest_value > previous_value THEN 'INCREASED'
                    WHEN metric_name <> 'health_score' AND latest_value < previous_value THEN 'DECREASED'
                    ELSE 'UNCHANGED'
                END,
                NULL::text
            FROM metric_pairs
            WHERE latest_value IS DISTINCT FROM previous_value
            ORDER BY
                CASE
                    WHEN metric_name = 'health_score' THEN 1
                    WHEN metric_name IN ('waiting_locks','long_queries_over_5m','max_replica_lag_seconds','max_slot_retained_wal_bytes') THEN 2
                    ELSE 3
                END,
                abs(latest_value - previous_value) DESC NULLS LAST
        $sql$;
    ELSE
        INSERT INTO pg_temp.observer_baseline_deviation_result (guidance)
        VALUES ('Observer repository is missing. Run 01_create_observer_repository.sql and capture at least two snapshots.');
    END IF;
END;
$$;

SELECT *
FROM pg_temp.observer_baseline_deviation_result;

-- SAMPLE_OUTPUT_BEGIN
-- metric_name                  | previous_value | latest_value | delta_value | delta_pct | deviation_signal
-- -----------------------------+----------------+--------------+-------------+-----------+--------------------
-- health_score                 |            100 |           80 |         -20 |    -20.00 | HEALTH_SCORE_DROPPED
-- max_slot_retained_wal_bytes  |              0 |   1073741824 |  1073741824 |           | INCREASED
-- SAMPLE_OUTPUT_END
