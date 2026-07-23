# PostgreSQL 360 Coverage Audit

Purpose: document how close this repository is to a 360-degree SME command-line toolkit for PostgreSQL operations.

## Current State

- SQL scripts: `248`.
- Operational folders: `42`, including the two legacy `27_*` folders.
- Header coverage: every SQL file has `PostgreSQL DBA Script`, `Purpose`, `Area`, `Usage`, `Sample Output`, and `Notes`.
- Sample coverage: every SQL file has an embedded `SAMPLE_OUTPUT_BEGIN` / `SAMPLE_OUTPUT_END` block.
- First-look dashboard: `38_observability_360/01_instance_health_360_dashboard.sql`.
- CloudWatch-style SQL mapping: `38_observability_360/02_cloudwatch_metric_equivalents.sql`.
- Complete RDS/Aurora PostgreSQL CloudWatch router: `41_aws_rds_aurora_postgresql/01_cloudwatch_metric_deep_dive_router.sql`.
- Observer-agent monitoring layer: `39_observer_agent_monitoring`.
- PgAdmin-safe PostgreSQL 15+ diagnosis layer: `40_pgadmin_safe_diagnostics`.
- Searchable script inventory: `SCRIPT_CATALOG.md`.

## What PostgreSQL SQL Can See Well

| Domain | Primary Scripts | Primary Sources |
| --- | --- | --- |
| Sessions, waits, locks | `38_observability_360/01_instance_health_360_dashboard.sql`, `38_observability_360/04_wait_event_hotspots.sql`, `06_activity_locks/*` | `pg_stat_activity`, `pg_locks` |
| Database workload | `38_observability_360/05_database_activity_metrics.sql`, `13_io_wal_checkpoints/01_database_io_profile.sql` | `pg_stat_database` |
| Table/index heat | `38_observability_360/06_table_index_activity_heatmap.sql`, `03_index_analysis/*`, `19_dml_optimization/*` | `pg_stat_user_tables`, `pg_stat_user_indexes` |
| Query workload | `38_observability_360/10_query_capture_quality_pgss.sql`, `11_performance_tuning/*`, `28_pgss_resource_attribution/*` | `pg_stat_statements` |
| PgAdmin-friendly top 10 deep dives | `11_performance_tuning/07_top_10_cpu_intensive_queries_pgadmin.sql`, `11_performance_tuning/08_top_10_temp_disk_spill_queries_pgadmin.sql`, `11_performance_tuning/09_top_10_memory_pressure_queries_pgadmin.sql`, `11_performance_tuning/10_active_top_10_runtime_pressure_pgadmin.sql` | Plain SQL, no `psql` meta commands |
| WAL/checkpoints/archive | `38_observability_360/07_wal_checkpoint_archiver_dashboard.sql`, `13_io_wal_checkpoints/*`, `30_backup_restore_pitr_dr/*` | `pg_stat_wal`, `pg_stat_bgwriter`, `pg_stat_checkpointer`, `pg_stat_archiver` |
| Vacuum/analyze/bloat | `38_observability_360/08_autovacuum_vacuum_analyze_progress.sql`, `07_vacuum_bloat/*`, `33_bgwriter_memory_pressure/03_autovacuum_worker_pressure.sql` | `pg_stat_progress_vacuum`, `pg_stat_progress_analyze`, `pg_stat_user_tables` |
| Replication/HA | `38_observability_360/09_replication_and_slot_dashboard.sql`, `08_replication_ha/*`, `36_cloud_provider_signals/03_replica_lag_failover_signals.sql` | `pg_stat_replication`, `pg_stat_wal_receiver`, `pg_replication_slots` |
| Capacity/growth | `38_observability_360/11_growth_and_capacity_snapshot_now.sql`, `15_capacity_forecasting/*`, `37_object_lifecycle_capacity/*` | `pg_database`, `pg_class`, repository snapshots |
| Backup/PITR/DR | `30_backup_restore_pitr_dr/*` | archive settings, archiver stats, replication state, optional evidence table |
| Cloud/provider correlation | `36_cloud_provider_signals/*`, `38_observability_360/02_cloudwatch_metric_equivalents.sql` | SQL-visible proxies plus provider-console checklist |
| Observer-agent monitoring | `39_observer_agent_monitoring/*` | `dba_observer` snapshots, findings, health score, baseline deviation, action queue |
| PgAdmin-safe diagnostics | `40_pgadmin_safe_diagnostics/*` | Plain SQL and temporary session-local helper functions, no `psql` meta commands |

## CloudWatch-Like Limits

PostgreSQL catalog SQL cannot portably expose every host/cloud metric. These still require CloudWatch, OS tools, managed-service APIs, or a monitoring agent:

- CPU utilization.
- Freeable memory and swap pressure.
- Filesystem free space and volume-level burst balance.
- Disk queue depth and storage device saturation.
- Network receive/transmit throughput.
- Host-level process memory for all backends.
- Cloud control-plane events such as failover, maintenance, storage scaling, and backup job internals.

The repository now handles this explicitly instead of pretending SQL can see everything:

- Use `38_observability_360/02_cloudwatch_metric_equivalents.sql` to map SQL-visible metrics to CloudWatch-style names.
- Use `41_aws_rds_aurora_postgresql/01_cloudwatch_metric_deep_dive_router.sql` for all 83 current PostgreSQL-applicable CloudWatch metric names and their focused deep-dive scripts.
- Use `36_cloud_provider_signals/05_cloud_incident_window_checklist.sql` when provider console evidence is required.

## Gap Status After This Pass

| Gap Found | Status |
| --- | --- |
| README script count stale at 198 | Fixed to `222`. |
| Missing obvious script title in SQL headers | Fixed for every SQL file. |
| Sample-output presence not obvious near top of scripts | Fixed for every SQL file. |
| Need command-line 360 starting point | Added `38_observability_360`. |
| Need CloudWatch-style metric mapping | Added `02_cloudwatch_metric_equivalents.sql`. |
| Need script discovery by purpose | Added `SCRIPT_CATALOG.md`. |
| Need symptom-to-script routing | Added `12_sme_triage_command_router.sql`. |
| Need pro observer-agent workflow | Added `39_observer_agent_monitoring` with capture, score, detect, classify, route, baseline deviation, SLA risk, and summary scripts. |
| Need diagnostics that run directly in pgAdmin Query Tool | Added `40_pgadmin_safe_diagnostics` with 12 plain-SQL PostgreSQL 15+ scripts and compatibility replacements for psql-meta diagnostics. |

## Recommended First-Use Flow

1. Run `38_observability_360/01_instance_health_360_dashboard.sql`.
2. If the signal is unclear, run `38_observability_360/12_sme_triage_command_router.sql`.
3. In pgAdmin Query Tool, start with `40_pgadmin_safe_diagnostics/12_pgadmin_safe_sme_diagnosis_router.sql` or `40_pgadmin_safe_diagnostics/09_pgadmin_safe_observer_health_dashboard.sql`.
4. Check stat coverage with `38_observability_360/03_stat_view_coverage_check.sql`.
5. Use the relevant deep-dive area from `SCRIPT_CATALOG.md`.
6. For historical growth/rate analysis, schedule `15_capacity_forecasting` and `37_object_lifecycle_capacity` snapshot scripts.
7. For continuous observer-agent monitoring, run `39_observer_agent_monitoring/01_create_observer_repository.sql` once, then schedule `39_observer_agent_monitoring/02_capture_observer_snapshot.sql`.
