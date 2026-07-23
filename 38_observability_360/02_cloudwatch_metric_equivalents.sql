/*
PostgreSQL DBA Script: CloudWatch Metric Equivalents
Purpose: Show live equivalents for common RDS/CloudWatch metrics and route the complete AWS PostgreSQL metric inventory to deeper diagnostics.
Area: Observability 360
Usage: Run when you need CloudWatch-like context from pgAdmin or psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. For all 83 current PostgreSQL-applicable metric names, run 41_aws_rds_aurora_postgresql/01_cloudwatch_metric_deep_dive_router.sql.
*/

CREATE TEMP TABLE IF NOT EXISTS obs360_cloudwatch_equivalent_report (
    cloud_metric text,
    sql_visible_value text,
    unit text,
    postgres_source text,
    visibility text,
    interpretation text,
    recommended_action text
);

TRUNCATE obs360_cloudwatch_equivalent_report;

INSERT INTO obs360_cloudwatch_equivalent_report
SELECT 'DatabaseConnections', count(*)::text, 'count', 'pg_stat_activity', 'SQL_VISIBLE',
       'Current backend connections.', 'Compare with max_connections and pool limits.'
FROM pg_stat_activity
UNION ALL
SELECT 'MaximumUsedTransactionIDs', max(age(datfrozenxid))::text, 'xids', 'pg_database', 'SQL_VISIBLE',
       'Oldest database-level transaction ID age.', 'Review freeze-age scripts if this approaches warning thresholds.'
FROM pg_database
UNION ALL
SELECT 'Deadlocks', sum(deadlocks)::text, 'count', 'pg_stat_database', 'SQL_VISIBLE',
       'Cumulative deadlocks since stats reset.', 'Review deadlock logs and transaction ordering.'
FROM pg_stat_database
UNION ALL
SELECT 'TransactionLogsGeneration', wal_bytes::text, 'bytes since reset', 'pg_stat_wal', 'SQL_VISIBLE_RATE_NEEDS_SNAPSHOTS',
       'Use two snapshots to calculate WAL bytes per second.', 'Use WAL/checkpoint dashboard and snapshot deltas.'
FROM pg_stat_wal
UNION ALL
SELECT 'OldestReplicationSlotLag', coalesce(max(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn))::text, '0'),
       'bytes', 'pg_replication_slots', 'SQL_VISIBLE',
       'WAL retained by the most lagging slot.', 'Review inactive or lagging replication slots.'
FROM pg_replication_slots
WHERE restart_lsn IS NOT NULL
UNION ALL
SELECT 'ReplicaLag', coalesce(max(extract(epoch FROM replay_lag))::text, '0'), 'seconds',
       'pg_stat_replication', 'SQL_VISIBLE_ON_PRIMARY',
       'Largest streaming replay lag reported by primary.', 'Review standby apply/replay health if nonzero or increasing.'
FROM pg_stat_replication
UNION ALL
SELECT 'FreeStorageSpace', NULL, 'bytes', 'CloudWatch/OS', 'HOST_OR_CLOUD_ONLY',
       'PostgreSQL can show relation/database size but not filesystem free space portably.',
       'Use CloudWatch, provider API, df, or storage monitoring.'
UNION ALL
SELECT 'CPUUtilization', NULL, 'percent', 'CloudWatch/OS', 'HOST_OR_CLOUD_ONLY',
       'SQL cannot directly read host CPU utilization portably.',
       'Use CloudWatch, Performance Insights, top, pidstat, or provider APIs.'
UNION ALL
SELECT 'FreeableMemory', NULL, 'bytes', 'CloudWatch/OS', 'HOST_OR_CLOUD_ONLY',
       'SQL can infer pressure from temp files, connections, and waits, but not free OS memory.',
       'Use CloudWatch/OS metrics and correlate with temp spills and waits.'
UNION ALL
SELECT 'NetworkReceiveThroughput', NULL, 'bytes/second', 'CloudWatch/OS', 'HOST_OR_CLOUD_ONLY',
       'SQL can show query/session activity, not NIC throughput.',
       'Use CloudWatch or OS network counters.'
UNION ALL
SELECT 'NetworkTransmitThroughput', NULL, 'bytes/second', 'CloudWatch/OS', 'HOST_OR_CLOUD_ONLY',
       'SQL can show query/session activity, not NIC throughput.',
       'Use CloudWatch or OS network counters.'
UNION ALL
SELECT 'DiskQueueDepth', NULL, 'count', 'CloudWatch/OS', 'HOST_OR_CLOUD_ONLY',
       'Use provider disk metrics; SQL proxies include read/write time and wait events.',
       'Correlate with pg_stat_io, wait events, and storage metrics.';

DO $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_io') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO obs360_cloudwatch_equivalent_report
            SELECT 'ReadIOPS', sum(reads)::text, 'operations since reset', 'pg_stat_io',
                   'SQL_VISIBLE_RATE_NEEDS_SNAPSHOTS',
                   'Use two pg_stat_io snapshots to calculate read operations per second.',
                   'Capture deltas over a known interval.'
            FROM pg_stat_io
            UNION ALL
            SELECT 'WriteIOPS', sum(writes)::text, 'operations since reset', 'pg_stat_io',
                   'SQL_VISIBLE_RATE_NEEDS_SNAPSHOTS',
                   'Use two pg_stat_io snapshots to calculate write operations per second.',
                   'Capture deltas over a known interval.'
            FROM pg_stat_io
            UNION ALL
            SELECT 'ReadLatency', round((sum(read_time) / NULLIF(sum(reads), 0))::numeric, 3)::text,
                   'milliseconds/read', 'pg_stat_io', 'SQL_VISIBLE_WHEN_TRACK_IO_TIMING_ON',
                   'Average read time if track_io_timing captures timing.',
                   'Enable track_io_timing when safe and review high-latency contexts.'
            FROM pg_stat_io
            UNION ALL
            SELECT 'WriteLatency', round((sum(write_time) / NULLIF(sum(writes), 0))::numeric, 3)::text,
                   'milliseconds/write', 'pg_stat_io', 'SQL_VISIBLE_WHEN_TRACK_IO_TIMING_ON',
                   'Average write time if track_io_timing captures timing.',
                   'Enable track_io_timing when safe and review high-latency contexts.'
            FROM pg_stat_io
        $sql$;
    ELSE
        INSERT INTO obs360_cloudwatch_equivalent_report
        VALUES (
            'ReadIOPS/WriteIOPS/ReadLatency/WriteLatency',
            NULL,
            'n/a',
            'pg_stat_io',
            'POSTGRESQL_16_PLUS_ONLY',
            'pg_stat_io is not available on this PostgreSQL version.',
            'On PostgreSQL 15, use pg_stat_database timing proxies and OS/cloud metrics.'
        );
    END IF;
END $$;

SELECT
    'step_01_cloudwatch_metric_map' AS report_section,
    cloud_metric,
    sql_visible_value,
    unit,
    postgres_source,
    visibility,
    interpretation,
    recommended_action
FROM obs360_cloudwatch_equivalent_report
ORDER BY cloud_metric;

-- SAMPLE_OUTPUT_BEGIN
-- report_section                 | cloud_metric         | sql_visible_value | postgres_source      | visibility
-- -------------------------------+----------------------+-------------------+----------------------+-------------------------------
-- step_01_cloudwatch_metric_map  | CPUUtilization       |                   | CloudWatch/OS        | HOST_OR_CLOUD_ONLY
-- step_01_cloudwatch_metric_map  | DatabaseConnections  | 42                | pg_stat_activity     | SQL_VISIBLE
-- SAMPLE_OUTPUT_END
