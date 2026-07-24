/*
PostgreSQL DBA Script: AWS Database Telemetry Completeness Audit
Purpose: Verify that CloudWatch service metrics, Database Insights load, Enhanced Monitoring, PostgreSQL statistics, logs, and events each have an explicit investigation boundary.
Area: AWS RDS and Aurora PostgreSQL
Usage: Run during monitoring design reviews and after AWS feature, engine, or instance-class changes.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only. SQL cannot prove that AWS alarms, Enhanced Monitoring, log exports, or Database Insights retention are enabled; verify those in AWS configuration.
*/
SELECT *
FROM (VALUES
    ('RDS_AURORA_CLOUDWATCH', 83, 'MAPPED', '01_cloudwatch_metric_deep_dive_router.sql', 'Instance, cluster, storage, serverless, replication, backup, and network service metrics.'),
    ('DATABASE_INSIGHTS_LOAD', 4, 'MAPPED', '10_database_insights_dbload_deep_dive.sql', 'DBLoad, DBLoadCPU, DBLoadNonCPU, and DBLoadRelativeToNumVCPUs.'),
    ('POSTGRESQL_ENGINE_STATS', NULL, 'LIVE_SQL', '38_observability_360/03_stat_view_coverage_check.sql', 'Sessions, waits, locks, SQL, I/O, WAL, checkpoints, vacuum, replication, XID, objects, and settings.'),
    ('ENHANCED_MONITORING_OS', NULL, 'AWS_ONLY', NULL, 'Per-process CPU/memory, load average, filesystem, disk, network, swap, and OS task detail delivered through CloudWatch Logs.'),
    ('PERFORMANCE_INSIGHTS_COUNTERS', NULL, 'AWS_DATABASE_INSIGHTS', '10_database_insights_dbload_deep_dive.sql', 'OS and engine counters queried through Database Insights or DB_PERF_INSIGHTS metric math.'),
    ('POSTGRESQL_LOG_EXPORTS', NULL, 'AWS_CONFIGURATION_REQUIRED', '31_logging_error_signatures/01_logging_configuration_sanity.sql', 'Errors, deadlocks, checkpoints, autovacuum, connections, disconnections, temp files, and slow SQL depend on logging configuration and CloudWatch Logs exports.'),
    ('RDS_EVENTS_AND_HEALTH', NULL, 'AWS_ONLY', NULL, 'Failover, reboot, maintenance, storage, certificate, backup, and service-health events are not PostgreSQL counters.'),
    ('CLOUDTRAIL_CONTROL_PLANE', NULL, 'AWS_ONLY', NULL, 'Parameter, instance, cluster, snapshot, security, and API configuration changes require CloudTrail.'),
    ('APPLICATION_TELEMETRY', NULL, 'APPLICATION_REQUIRED', NULL, 'Request latency, errors, retries, pool waits, ORM behavior, and business throughput require application instrumentation.')
) AS p(telemetry_plane, mapped_metric_count, coverage_status, first_script, responsibility)
ORDER BY telemetry_plane;

SELECT
    current_setting('server_version') AS server_version,
    to_regclass('pg_catalog.pg_stat_activity') IS NOT NULL AS activity_available,
    to_regclass('pg_catalog.pg_locks') IS NOT NULL AS locks_available,
    to_regclass('pg_catalog.pg_stat_database') IS NOT NULL AS database_stats_available,
    to_regclass('pg_catalog.pg_stat_wal') IS NOT NULL AS wal_stats_available,
    to_regclass('pg_catalog.pg_stat_io') IS NOT NULL AS pg_stat_io_available,
    to_regclass('pg_catalog.pg_stat_replication') IS NOT NULL AS replication_stats_available,
    to_regclass('pg_catalog.pg_stat_statements') IS NOT NULL
        OR to_regclass('public.pg_stat_statements') IS NOT NULL AS pg_stat_statements_available,
    current_setting('track_io_timing') AS track_io_timing,
    current_setting('track_wal_io_timing') AS track_wal_io_timing,
    current_setting('compute_query_id') AS compute_query_id,
    CASE
        WHEN current_setting('track_io_timing') = 'off' THEN 'REVIEW_IO_TIMING_VISIBILITY'
        WHEN NOT (
            to_regclass('pg_catalog.pg_stat_statements') IS NOT NULL
            OR to_regclass('public.pg_stat_statements') IS NOT NULL
        ) THEN 'REVIEW_QUERY_HISTORY_VISIBILITY'
        ELSE 'CORE_SQL_TELEMETRY_READY'
    END AS sql_telemetry_status;

SELECT *
FROM (VALUES
    ('DBLoad or DBLoadNonCPU spike', '10_database_insights_dbload_deep_dive.sql'),
    ('DiskQueueDepth spike', '11_disk_queue_depth_deep_dive.sql'),
    ('BufferCacheHitRatio, ReadIOPS, or WriteIOPS spike', '12_buffer_cache_read_write_iops_deep_dive.sql'),
    ('CPU, memory, swap, or ACU spike', '02_compute_memory_serverless_pressure.sql'),
    ('WAL, checkpoint, or log-volume spike', '05_wal_checkpoint_log_volume_pressure.sql'),
    ('Replica, slot, or Global Database spike', '06_replication_slots_global_database_pressure.sql'),
    ('XID or vacuum pressure', '07_xid_vacuum_wraparound_pressure.sql'),
    ('Capacity, backup, or billing growth', '08_capacity_backup_billing_correlates.sql'),
    ('Network throughput spike', '09_network_workload_correlates.sql')
) AS r(observed_signal, first_script);

-- SAMPLE_OUTPUT_BEGIN
-- telemetry_plane | mapped_metric_count | coverage_status | first_script | responsibility
-- server_version | activity_available | pg_stat_io_available | pg_stat_statements_available | sql_telemetry_status
-- SAMPLE_OUTPUT_END
