# AWS RDS and Aurora PostgreSQL Metric Deep Dives

Purpose: Route every currently documented CloudWatch metric applicable to RDS PostgreSQL or Aurora PostgreSQL to actionable database evidence.

## Coverage

- Official AWS/RDS applicability rows reviewed: `106`.
- Unique RDS/Aurora service metric names: `83`.
- Database Insights load metric names: `4`.
- Total exact metric routes: `87`.
- RDS PostgreSQL metric names: `46`.
- Aurora PostgreSQL metric names: `60` applicability rows, including service overlap and one repeated cluster/instance metric.
- PostgreSQL target: `15+`.
- Execution: pgAdmin Query Tool or `psql`.

The count is not permanently fixed. AWS adds and removes metrics by engine, instance class, storage type, Region, and feature. Use the router as the checked-in baseline and compare it periodically with the AWS documentation or `aws cloudwatch list-metrics`.

## Run Order

1. `01_cloudwatch_metric_deep_dive_router.sql`
2. Run the script named in `deep_dive_script` for the alarmed metric.
3. Compare SQL evidence with the same CloudWatch alarm window and statistic.
4. Run `13_database_telemetry_completeness_audit.sql` during monitoring design reviews.

## Deep-Dive Packs

- `02_compute_memory_serverless_pressure.sql`
- `03_connections_commits_deadlocks.sql`
- `04_storage_io_cache_temp_pressure.sql`
- `05_wal_checkpoint_log_volume_pressure.sql`
- `06_replication_slots_global_database_pressure.sql`
- `07_xid_vacuum_wraparound_pressure.sql`
- `08_capacity_backup_billing_correlates.sql`
- `09_network_workload_correlates.sql`
- `10_database_insights_dbload_deep_dive.sql`
- `11_disk_queue_depth_deep_dive.sql`
- `12_buffer_cache_read_write_iops_deep_dive.sql`
- `13_database_telemetry_completeness_audit.sql`

## Interpretation Boundary

- `SQL_DIRECT`: PostgreSQL exposes the same or a closely matching engine counter.
- `SQL_RATE_NEEDS_SNAPSHOTS`: calculate a delta between two snapshots matching the CloudWatch period.
- `SQL_CORRELATION`: SQL explains database contributors but cannot reproduce the AWS metric exactly.
- `AWS_ONLY`: the metric belongs to the host, EBS, Aurora storage, serverless control plane, backup billing, or cross-Region service layer.

Do not compare a cumulative PostgreSQL counter directly with a one-minute CloudWatch rate. Match the time window, statistic, dimensions, node role, and stats-reset boundary.

## Official Sources

- RDS CloudWatch metrics: `https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-metrics.html`
- Aurora CloudWatch metrics: `https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraMonitoring.Metrics.html`
- Performance Insights counters: `https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_PerfInsights_Counters.html`
- Database Insights / Performance Insights CloudWatch load metrics: `https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.Cloudwatch.html`
