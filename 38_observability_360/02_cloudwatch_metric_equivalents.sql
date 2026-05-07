/*
PostgreSQL DBA Script: CloudWatch Metric Equivalents
Purpose: Map common RDS/CloudWatch metrics to PostgreSQL SQL-visible counters and identify host-only gaps.
Area: Observability 360
Usage: Run when you need CloudWatch-like context from psql and want to know which metrics require cloud/OS tools.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. SQL cannot directly see CPU, free memory, OS disk queue, network throughput, or cloud storage free space.
*/
SELECT (current_setting('server_version_num')::int >= 160000) AS has_pg_stat_io \gset

WITH live AS (
    SELECT 'DatabaseConnections' AS cloud_metric,
           count(*)::text AS sql_visible_value,
           'count' AS unit,
           'pg_stat_activity' AS postgres_source,
           'SQL_VISIBLE' AS visibility,
           'Current backend connections.' AS interpretation
    FROM pg_stat_activity
    UNION ALL
    SELECT 'MaxUsedTransactionIDs',
           max(age(datfrozenxid))::text,
           'xids',
           'pg_database',
           'SQL_VISIBLE',
           'Oldest database-level transaction ID age.'
    FROM pg_database
    UNION ALL
    SELECT 'Deadlocks',
           sum(deadlocks)::text,
           'count',
           'pg_stat_database',
           'SQL_VISIBLE',
           'Cumulative deadlocks since stats reset.'
    FROM pg_stat_database
    UNION ALL
    SELECT 'TransactionLogsGeneration',
           wal_bytes::text,
           'bytes since reset',
           'pg_stat_wal',
           'SQL_VISIBLE_RATE_NEEDS_SNAPSHOTS',
           'Use two snapshots to calculate WAL bytes per second.'
    FROM pg_stat_wal
    UNION ALL
    SELECT 'OldestReplicationSlotLag',
           coalesce(max(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn))::text, '0'),
           'bytes',
           'pg_replication_slots',
           'SQL_VISIBLE',
           'WAL retained by the most lagging slot.'
    FROM pg_replication_slots
    WHERE restart_lsn IS NOT NULL
    UNION ALL
    SELECT 'ReplicaLag',
           coalesce(max(extract(epoch FROM replay_lag))::text, '0'),
           'seconds',
           'pg_stat_replication',
           'SQL_VISIBLE_ON_PRIMARY',
           'Largest streaming replay lag reported by primary.'
    FROM pg_stat_replication
    UNION ALL
    SELECT 'FreeStorageSpace',
           NULL,
           'bytes',
           'CloudWatch/OS',
           'HOST_OR_CLOUD_ONLY',
           'PostgreSQL can show relation/database size but not filesystem free space portably.'
    UNION ALL
    SELECT 'CPUUtilization',
           NULL,
           'percent',
           'CloudWatch/OS',
           'HOST_OR_CLOUD_ONLY',
           'Use CloudWatch, Performance Insights, top, pidstat, or provider APIs.'
    UNION ALL
    SELECT 'FreeableMemory',
           NULL,
           'bytes',
           'CloudWatch/OS',
           'HOST_OR_CLOUD_ONLY',
           'SQL can infer pressure from temp files, connections, and waits, but not free OS memory.'
    UNION ALL
    SELECT 'NetworkReceiveThroughput',
           NULL,
           'bytes/second',
           'CloudWatch/OS',
           'HOST_OR_CLOUD_ONLY',
           'SQL can show query/session activity, not NIC throughput.'
    UNION ALL
    SELECT 'NetworkTransmitThroughput',
           NULL,
           'bytes/second',
           'CloudWatch/OS',
           'HOST_OR_CLOUD_ONLY',
           'SQL can show query/session activity, not NIC throughput.'
    UNION ALL
    SELECT 'DiskQueueDepth',
           NULL,
           'count',
           'CloudWatch/OS',
           'HOST_OR_CLOUD_ONLY',
           'Use provider disk metrics; SQL proxies include read/write time and wait events.'
)
SELECT cloud_metric,
       sql_visible_value,
       unit,
       postgres_source,
       visibility,
       interpretation
FROM live
ORDER BY cloud_metric;

\if :has_pg_stat_io
SELECT 'ReadIOPS' AS cloud_metric,
       sum(reads)::text AS sql_visible_value,
       'operations since reset' AS unit,
       'pg_stat_io' AS postgres_source,
       'SQL_VISIBLE_RATE_NEEDS_SNAPSHOTS' AS visibility,
       'Use two pg_stat_io snapshots to calculate read operations per second.' AS interpretation
FROM pg_stat_io
UNION ALL
SELECT 'WriteIOPS',
       sum(writes)::text,
       'operations since reset',
       'pg_stat_io',
       'SQL_VISIBLE_RATE_NEEDS_SNAPSHOTS',
       'Use two pg_stat_io snapshots to calculate write operations per second.'
FROM pg_stat_io
UNION ALL
SELECT 'ReadLatency',
       round((sum(read_time) / NULLIF(sum(reads), 0))::numeric, 3)::text,
       'milliseconds/read',
       'pg_stat_io',
       'SQL_VISIBLE_WHEN_TRACK_IO_TIMING_ON',
       'Average read time if track_io_timing captures timing.'
FROM pg_stat_io
UNION ALL
SELECT 'WriteLatency',
       round((sum(write_time) / NULLIF(sum(writes), 0))::numeric, 3)::text,
       'milliseconds/write',
       'pg_stat_io',
       'SQL_VISIBLE_WHEN_TRACK_IO_TIMING_ON',
       'Average write time if track_io_timing captures timing.'
FROM pg_stat_io
ORDER BY cloud_metric;
\else
SELECT 'ReadIOPS/WriteIOPS/ReadLatency/WriteLatency' AS cloud_metric,
       NULL AS sql_visible_value,
       'n/a' AS unit,
       'pg_stat_io' AS postgres_source,
       'POSTGRESQL_16_PLUS_ONLY' AS visibility,
       'Use 13_io_wal_checkpoints and pg_stat_database timing proxies on PostgreSQL 15.' AS interpretation;
\endif

-- SAMPLE_OUTPUT_BEGIN
-- cloud_metric              | sql_visible_value | unit                  | postgres_source      | visibility
-- --------------------------+-------------------+-----------------------+----------------------+-------------------------------
-- CPUUtilization            |                   | percent               | CloudWatch/OS        | HOST_OR_CLOUD_ONLY
-- DatabaseConnections       | 42                | count                 | pg_stat_activity     | SQL_VISIBLE
-- OldestReplicationSlotLag  | 104857600         | bytes                 | pg_replication_slots | SQL_VISIBLE
-- ReadIOPS                  | 938374            | operations since reset| pg_stat_io           | SQL_VISIBLE_RATE_NEEDS_SNAPSHOTS
-- SAMPLE_OUTPUT_END
