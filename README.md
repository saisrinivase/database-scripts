# saisrinivase - PostgreSQL Administration Scripts (360-Degree)

Purpose: Central, area-based SQL script repository for PostgreSQL DBAs.

## Scope

- Coverage: 38 operational areas.
- Current SQL scripts: 198.
- Style: every script includes `Purpose`, `Area`, and `Usage` headers.
- Goal: enable any DBA/engineer to open an area folder and run purpose-specific scripts quickly.

## Areas

- `00_environment`: instance fingerprint, extension baseline, catalog object inventory.
- `01_database_size`: database/tablespace size and top-level storage breakdown.
- `02_table_storage`: table-level storage distribution and growth baselines.
- `03_index_analysis`: index size/use, unused and duplicate index candidates.
- `04_toast_lob_blob`: TOAST, LOB/BLOB footprint and heavy-object detection.
- `05_partitioning`: partition inventory, distribution, and recommendation heuristics.
  - Includes SME decision scorecard, target-table deep advisor, and 5GB+ time-series lab generator.
- `06_activity_locks`: active sessions, blockers, waits, long transactions.
- `07_vacuum_bloat`: bloat heuristics, freeze age, autovacuum visibility.
- `08_replication_ha`: replication lag, slots, standby replay, WAL rates.
- `09_security_roles`: role privilege and object-access auditing.
- `10_maintenance_monitoring`: checkpoints, cache ratio, config drift, connection capacity.
- `11_performance_tuning`: query-level hotspots and tuning-related settings.
- `12_planner_statistics`: planner stats quality, analyze drift, extended stats candidates.
- `13_io_wal_checkpoints`: read/write pressure, temp usage, WAL archiver/checkpoint stress.
- `14_connection_workload`: connection behavior, limits, backend type, transaction hygiene.
- `15_capacity_forecasting`: snapshot repository, capture scripts, growth reports.
- `16_internals_deep_dive`: XID/multixact aging, relfilenodes, dependency and fork internals.
- `17_execution_plans`: plan diagnostics, EXPLAIN templates, plan red-flag candidates.
- `18_long_queries_full_scans`: long query tracking and full-scan hotspots.
- `19_dml_optimization`: write amplification, HOT update ratio, FK index support.
- `20_design_matters`: schema design anti-pattern diagnostics.
- `21_configuration_parameters`: performance-related configuration baselines.
- `22_application_orm_performance`: ORM and application-side performance pitfalls.
- `23_functions_dynamic_sql`: function and dynamic SQL performance/security review.
- `24_complex_filter_search`: LIKE/ILIKE, JSON/array, GIN/GiST/BRIN and FTS diagnostics.
- `25_oltp_olap_goals`: workload goal alignment and classification.
- `26_physical_cloud_diagnostics`: physical/cloud root-cause indicators.
- `27_high_speed_tuning`: fast bottleneck triage, parameter advisor, and missing-index detection.
- `27_migration_validation`: Oracle-to-PostgreSQL migration health checks and issue simulation/fix flows.
- `28_pgss_resource_attribution`: pg_stat_statements-based CPU/IO/memory-spill percentage attribution.
- `29_object_inventory_health`: object-centric deep diagnostics (TABLE/VIEW/MVIEW/TABLESPACE/SEQUENCE/INDEX/TRIGGER/GRANT/FUNCTION/PROCEDURE/PARTITION/TYPE/FDW/INSERT-COPY) plus PACKAGE/SYNONYM mapping and KETTLE signals.
- `30_backup_restore_pitr_dr`: backup/PITR configuration checks, WAL archive readiness, restore-to-timestamp quick test, and DR evidence.
- `31_logging_error_signatures`: logging parameter sanity, error-signature indicators, and slow-query/log correlation.
- `32_upgrade_patch_readiness`: pre-upgrade risk gates, extension drift/dependency checks, collation mismatch, and post-upgrade watchlists.
- `33_bgwriter_memory_pressure`: checkpointer/bgwriter, WAL writer/archiver, autovacuum, parallel workers, and spill pressure triage.
- `34_consistency_integrity_checks`: invalid object checks, checksum posture, TOAST/catalog anomaly signals, and amcheck readiness.
- `35_pooler_proxy_diagnostics`: saturation/churn indicators, prepared statement risk, transaction pooling incompatibility patterns, and proxy inventory.
- `36_cloud_provider_signals`: optional managed-service fingerprint, parameter drift/pending-restart, replica lag/failover, and cloud incident checklist.

## Numbering Note

- Both `27_high_speed_tuning` and `27_migration_validation` are retained as-is for backward compatibility with existing references.

## Performance Topic Coverage

See `PERFORMANCE_TUNING_COVERAGE.md` for direct mapping from performance topics to scripts.
See `27_high_speed_tuning/README.md` for a fast triage run order.

## Object Topic Coverage

See `OBJECT_COVERAGE_MATRIX.md` for direct mapping from object types/issues to scripts.

## Internals Mapping

See `INTERNALS_COVERAGE_MATRIX.md` for topic-to-internals source mapping.

## Version Compatibility

See `VERSION_COMPATIBILITY.md`.

## Sample Output Convention

- Every SQL script includes an embedded sample output section at the bottom.
- Section markers: `-- SAMPLE_OUTPUT_BEGIN` ... `-- SAMPLE_OUTPUT_END`.
- Sample output is for quick understanding; values vary by environment and runtime state.
- Historical full-run outputs are retained in `_validation_runs/` for audit purposes.

## Operational Notes

- Candidate scripts (for example index drop, partitioning, extended statistics) are advisory; review plans and workload before action.
- Target support is PostgreSQL `15` through `18`.
- Current validated execution in this workspace: PostgreSQL `18.0`.
- A subset of scripts contains `psql` version guards (`\\if`/`\\gset`) to switch logic between `15/16` and `17/18` system view changes.
- Some scripts require extensions/features:
  - `pg_stat_statements` for statement-level tuning scripts.
  - `pg_stat_wal` (PostgreSQL 14+) for WAL counter scripts.
  - `pg_stat_io` (PostgreSQL 16+) for detailed I/O scripts.
  - Access to `pg_largeobject` for large object analysis.
- Capacity area (`15_capacity_forecasting`) stores snapshots in schema `dba_metrics`; run create script first.
