# PostgreSQL Version Compatibility

Purpose: Document compatibility expectations for PostgreSQL 15-18.

## Summary

- Target versions: `PostgreSQL 15, 16, 17, 18`.
- Validated in this workspace: `PostgreSQL 18.0` (full run, all scripts passed).
- Validation artifact: `/Users/saiendla/Documents/PostgreSQl SCripts /postgres_admin_scripts/_validation_runs/20260218_174311/report.md`.

## Guarded Cross-Version Scripts

These scripts auto-switch logic with `psql` meta commands (`\gset`, `\if`) for view/column differences:

- `07_vacuum_bloat/05_vacuum_progress.sql`
  - Uses `max_dead_tuples/num_dead_tuples` on 15/16.
  - Uses `max_dead_tuple_bytes/dead_tuple_bytes/num_dead_item_ids` on 17/18.

- `10_maintenance_monitoring/01_bgwriter_checkpoint_stats.sql`
- `13_io_wal_checkpoints/05_checkpoint_pressure_indicators.sql`
- `26_physical_cloud_diagnostics/03_checkpoint_fsync_pressure.sql`
- `27_high_speed_tuning/01_bottleneck_overview_dashboard.sql`
  - Uses `pg_stat_bgwriter` checkpoint columns on 15/16.
  - Uses `pg_stat_checkpointer` + `pg_stat_bgwriter` split metrics on 17/18.

- `13_io_wal_checkpoints/07_pg_stat_io_overview_pg16_plus.sql`
  - Runs full query on 16+.
  - Returns informational message on 15.

## Feature/Extension Requirements

- `pg_stat_statements` required for query-level performance and resource attribution scripts.
- `pg_stat_wal` scripts require PostgreSQL 14+ (covered by 15-18 target).
- `pg_stat_io` requires PostgreSQL 16+.

## Important Execution Note

- Version-guarded scripts rely on `psql` meta commands.
- Recommended execution path: `psql -f <script.sql>`.
