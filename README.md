# saisrinivase - PostgreSQL Administration Scripts (360-Degree)

Purpose: Central, area-based SQL script repository for PostgreSQL DBAs.

## Quick Start

1. Pick an area folder based on your issue (size, locks, performance, migration, internals, etc.).
2. Run a script with `psql -d <database> -f <area>/<script>.sql`.
3. Compare your result with the embedded sample output at the bottom of the same script.
4. Use `SCRIPT_CATALOG.md` to search by purpose, or start with `38_observability_360/01_instance_health_360_dashboard.sql` for a CloudWatch-style first look.
5. Use coverage maps (`PERFORMANCE_TUNING_COVERAGE.md`, `OBJECT_COVERAGE_MATRIX.md`, `INTERNALS_COVERAGE_MATRIX.md`) for cross-area troubleshooting.

## Scope

- Coverage: `40` operational folders, including two legacy `27_*` folders retained for compatibility.
- Current SQL scripts: `222`.
- Script style: every SQL file includes `PostgreSQL DBA Script`, `Purpose`, `Area`, `Usage`, `Sample Output`, and `Notes` headers.
- Goal: any DBA/engineer can open an area and run purpose-specific scripts quickly.

## Area Index

- `00_environment`: instance fingerprint, extension baseline, catalog object inventory.
- `01_database_size`: database/tablespace size and top-level storage breakdown.
- `02_table_storage`: table-level storage distribution and growth baselines.
- `03_index_analysis`: index size/use, unused and duplicate index candidates.
- `04_toast_lob_blob`: TOAST, LOB/BLOB footprint and heavy-object detection.
- `05_partitioning`: partition inventory, distribution, recommendation heuristics, SME scorecard, target-table advisor, 5GB+ lab generator.
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
- `27_high_speed_tuning`: fast bottleneck triage, parameter advisor, missing-index detection.
- `27_migration_validation`: Oracle-to-PostgreSQL migration health checks and issue simulation/fix flows.
- `28_pgss_resource_attribution`: pg_stat_statements-based CPU/IO/memory-spill percentage attribution.
- `29_object_inventory_health`: deep diagnostics for TABLE/VIEW/MVIEW/TABLESPACE/SEQUENCE/INDEX/TRIGGER/GRANT/FUNCTION/PROCEDURE/PARTITION/TYPE/FDW/INSERT-COPY, plus PACKAGE/SYNONYM mapping and KETTLE signals.
- `30_backup_restore_pitr_dr`: backup/PITR checks, archive readiness, restore-to-timestamp quick test, DR evidence.
- `31_logging_error_signatures`: logging sanity, error-signature indicators, slow-query/log correlation.
- `32_upgrade_patch_readiness`: pre-upgrade gates, extension drift/dependencies, collation mismatch, post-upgrade watchlists.
- `33_bgwriter_memory_pressure`: checkpointer/bgwriter, WAL writer/archiver, autovacuum, parallel workers, spill pressure triage.
- `34_consistency_integrity_checks`: invalid object checks, checksum posture, TOAST/catalog anomaly signals, amcheck readiness.
- `35_pooler_proxy_diagnostics`: saturation/churn indicators, prepared statement risk, transaction pooling incompatibility, proxy inventory.
- `36_cloud_provider_signals`: optional managed-service fingerprint, parameter drift, replica lag/failover, cloud incident checklist.
- `37_object_lifecycle_capacity`: lifecycle repository, DDL event tracking, object growth, monthly capacity reports, and advisory views.
- `38_observability_360`: CloudWatch-style command-line dashboards, metric equivalents, stat coverage checks, waits, WAL/checkpoint/archive, vacuum/analyze, replication, pg_stat_statements capture quality, and SME triage routing.

Note: both `27_high_speed_tuning` and `27_migration_validation` are intentionally retained for backward compatibility.

## Coverage Maps

- Performance topic map: `PERFORMANCE_TUNING_COVERAGE.md`
- Object topic map: `OBJECT_COVERAGE_MATRIX.md`
- Internals topic map: `INTERNALS_COVERAGE_MATRIX.md`
- Script catalog: `SCRIPT_CATALOG.md`
- 360 coverage audit: `POSTGRES_360_COVERAGE_AUDIT.md`
- Fast triage order: `27_high_speed_tuning/README.md`
- Version compatibility details: `VERSION_COMPATIBILITY.md`

## Sample Output Convention

- Every SQL script includes embedded sample output at the bottom.
- Markers: `-- SAMPLE_OUTPUT_BEGIN` and `-- SAMPLE_OUTPUT_END`.
- Samples are for quick understanding; values vary by environment and runtime state.
- Historical full validation outputs are retained in `_validation_runs/`.

## Operational Notes

- Candidate scripts (index drop, partitioning, extended statistics, etc.) are advisory; review plans and workload before changes.
- Target support: PostgreSQL `15` through `18`.
- Current validated execution in this workspace: PostgreSQL `18.3` for the new observability pack; historical full-run artifact used PostgreSQL `18.0`.
- Some scripts use `psql` guards (`\\if`, `\\gset`) to support differences between `15/16` and `17/18` views/columns.

## Extension/Feature Dependencies

- `pg_stat_statements` for statement-level tuning scripts.
- `pg_stat_wal` (PostgreSQL 14+) for WAL counter scripts.
- `pg_stat_io` (PostgreSQL 16+) for detailed I/O scripts.
- Access to `pg_largeobject` for large object analysis.
- Capacity area (`15_capacity_forecasting`) stores snapshots in schema `dba_metrics`; run repository/create script first.
