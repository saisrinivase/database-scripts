# PostgreSQL Version Compatibility

Purpose: Document compatibility expectations for PostgreSQL 15-18.

## Summary

- Target versions: `PostgreSQL 15, 16, 17, 18`.
- Validated in this workspace: `PostgreSQL 18.0` (full run, all scripts passed).
- Latest targeted validation in this workspace: `38_observability_360/*.sql` passed on PostgreSQL `18.3`.
- Latest observer-agent validation in this workspace: `39_observer_agent_monitoring/*.sql` passed on PostgreSQL `18.3`.
- Validation artifact: `_validation_runs/20260218_174311/report.md`.
- Object inventory pack validation artifact: `29_object_inventory_health/samples_20260218_pgbench_test/summary.tsv`.

## Guarded Cross-Version Scripts

These scripts auto-switch logic with `psql` meta commands (`\gset`, `\if`) for view/column differences:

- `07_vacuum_bloat/05_vacuum_progress.sql`
  - Uses `max_dead_tuples/num_dead_tuples` on 15/16.
  - Uses `max_dead_tuple_bytes/dead_tuple_bytes/num_dead_item_ids` on 17/18.

- `10_maintenance_monitoring/01_bgwriter_checkpoint_stats.sql`
- `13_io_wal_checkpoints/05_checkpoint_pressure_indicators.sql`
- `26_physical_cloud_diagnostics/03_checkpoint_fsync_pressure.sql`
- `27_high_speed_tuning/01_bottleneck_overview_dashboard.sql`
- `38_observability_360/01_instance_health_360_dashboard.sql`
- `38_observability_360/07_wal_checkpoint_archiver_dashboard.sql`
  - Uses `pg_stat_bgwriter` checkpoint columns on 15/16.
  - Uses `pg_stat_checkpointer` + `pg_stat_bgwriter` split metrics on 17/18.

- `13_io_wal_checkpoints/07_pg_stat_io_overview_pg16_plus.sql`
- `38_observability_360/02_cloudwatch_metric_equivalents.sql`
  - Runs full query on 16+.
  - Returns informational message on 15.

- `29_object_inventory_health/18_object_query_hotspots_pgss.sql`
- `38_observability_360/10_query_capture_quality_pgss.sql`
  - Uses `psql` guard logic.
  - Runs hotspot query when `pg_stat_statements` is installed.
  - Returns guidance row when extension is missing.

## Feature/Extension Requirements

- `pg_stat_statements` required for query-level performance and resource attribution scripts.
- `pg_stat_wal` scripts require PostgreSQL 14+ (covered by 15-18 target).
- `pg_stat_io` requires PostgreSQL 16+.
- `pg_stat_progress_copy` is used in `29_object_inventory_health/13_insert_copy_activity.sql` (available in 15-18 target range).
- `38_observability_360` scripts use only PostgreSQL SQL-visible metrics; host/cloud-only metrics still require CloudWatch, OS tools, or provider APIs.
- `39_observer_agent_monitoring` stores SQL-visible observer snapshots in schema `dba_observer`; run the repository setup script first.

## Important Execution Note

- Version-guarded scripts rely on `psql` meta commands.
- Recommended execution path: `psql -f <script.sql>`.
