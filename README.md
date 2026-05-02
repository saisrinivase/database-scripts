# saisrinivase - Oracle Database Administration Scripts (360-Degree)

Purpose: Central, area-based SQL script repository for Oracle Database DBAs and engineers.

## Quick Start

1. Switch to this branch: `git checkout oracle`.
2. Pick an area folder based on the issue you are troubleshooting.
3. Run a script with SQL*Plus or SQLcl, for example: `sqlplus / as sysdba @00_environment/01_server_instance_overview.sql`.
4. Most scripts are read-only diagnostics. DDL/lab scripts include clear `CREATE` or `DBMS_SCHEDULER` statements and should be reviewed before execution.

## Scope

- Coverage: `39` operational areas.
- Current Oracle SQL scripts: `258`.
- Script style: every SQL file includes Purpose, Area, Usage, and Notes headers.
- Primary views used: `DBA_*`, `ALL_*`, `V$*`, `GV$*`, `DBA_HIST_*`, and Oracle built-in packages such as `DBMS_XPLAN`, `DBMS_STATS`, and `DBMS_SCHEDULER`.
- Expanded growth/performance pack includes FRA/archive growth, AWR tablespace/database growth, AWR SQLSTAT, ASH, SQL Monitor, DBMS_XPLAN, and capacity forecast scripts.

## Area Index

- `00_environment` (3 scripts): Oracle instance, database, option, and catalog inventory.
- `01_database_size` (11 scripts): Database, tablespace, datafile, temp file, and segment size diagnostics.
- `02_table_storage` (4 scripts): Table storage, segment allocation, row counts, and storage attributes.
- `03_index_analysis` (4 scripts): Index storage, visibility, duplication, selectivity, and maintenance candidates.
- `04_lob_blob_storage` (4 scripts): LOB/BLOB storage, SecureFiles, BasicFiles, compression, deduplication, and top LOB segments.
- `05_partitioning` (7 scripts): Partitioned table, partition segment, indexing, and recommendation checks.
- `06_activity_locks` (4 scripts): Active sessions, blockers, wait events, locks, and long-running transactions.
- `07_segment_space_reclaim` (5 scripts): Segment space reclaim, stale statistics, undo retention, and Segment Advisor signals.
- `08_replication_ha` (10 scripts): Data Guard, archivelog, redo generation, standby apply, and high availability posture.
- `09_security_roles` (4 scripts): Users, roles, system privileges, object grants, profiles, and exposure checks.
- `10_maintenance_monitoring` (5 scripts): DB writer, cache, checkpoint, top SQL, parameter drift, and capacity monitoring.
- `11_performance_tuning` (15 scripts): Top SQL, temp-heavy SQL, I/O-heavy SQL, parameter tuning, and PL/SQL hotspots.
- `12_planner_statistics` (10 scripts): Optimizer statistics quality, stale objects, histogram and extension inventory, and optimizer parameters.
- `13_io_redo_checkpoints` (10 scripts): Datafile I/O, object I/O, redo, archiver, checkpoint, and temp pressure.
- `14_connection_workload` (6 scripts): Session distribution, idle sessions, connection capacity, and distributed transaction status.
- `15_capacity_forecasting` (12 scripts): Capacity snapshot repository, capture scripts, and growth reports.
- `16_internals_deep_dive` (6 scripts): Undo, extents, segment internals, dependencies, LOB internals, and retention profiles.
- `17_execution_plans` (8 scripts): Plan capture, DBMS_XPLAN templates, and plan red-flag candidates.
- `18_long_queries_full_scans` (4 scripts): Long-running SQL and full scan workload diagnostics.
- `19_dml_optimization` (4 scripts): Write-heavy tables, row movement, index support for foreign keys, and DML pressure.
- `20_design_matters` (4 scripts): Schema design anti-patterns such as missing primary keys, wide tables, and high-null columns.
- `21_configuration_parameters` (4 scripts): Oracle initialization parameter baselines for performance, redo, stats, and connections.
- `22_application_orm_performance` (4 scripts): Application and ORM query patterns, select-star risk, chatty SQL, and idle transaction behavior.
- `23_functions_dynamic_sql` (4 scripts): PL/SQL procedure/function execution, dynamic SQL, security definer analogs, and triggers.
- `24_complex_filter_search` (4 scripts): LIKE, JSON, XML, Oracle Text, spatial, and domain index diagnostics.
- `25_oltp_olap_goals` (4 scripts): Workload classification and OLTP/OLAP pressure indicators.
- `26_physical_cloud_diagnostics` (4 scripts): Platform fingerprint, storage, wait, checkpoint, and managed-service signals.
- `27_high_speed_tuning` (6 scripts): Fast triage dashboards and action queues for bottleneck diagnosis.
- `27_oracle_health_validation` (9 scripts): Oracle health reports, sanity gates, and optional lab issue scripts.
- `28_sql_resource_attribution` (8 scripts): SQL resource attribution by SQL ID, service, parsing schema, and infrastructure tier.
- `29_object_inventory_health` (18 scripts): Deep object inventory and health checks for tables, indexes, constraints, PL/SQL, partitions, grants, DB links, and synonyms.
- `30_backup_restore_pitr_dr` (9 scripts): RMAN, archivelog, restore point, PITR, and Data Guard evidence.
- `31_logging_error_signatures` (4 scripts): ADR, alert log, trace, error signatures, slow SQL, lock waits, and deadlock indicators.
- `32_upgrade_patch_readiness` (6 scripts): Version, component, SQL patch, invalid object, NLS, and post-upgrade regression checks.
- `33_db_writer_memory_pressure` (5 scripts): DB writer, checkpoint, redo writer, stats jobs, parallel workers, SGA/PGA, and temp spill pressure.
- `34_consistency_integrity_checks` (5 scripts): Invalid objects, corruption views, LOB dictionary signals, and validate-structure commands.
- `35_pooler_proxy_diagnostics` (5 scripts): Connection saturation, session distribution, cursor cache, shared server, and proxy/client signals.
- `36_cloud_provider_signals` (7 scripts): Managed-service fingerprints, parameter drift, replica lag/failover, and incident-window evidence.
- `37_object_lifecycle_capacity` (12 scripts): Object lifecycle repository, DDL trigger, snapshots, advisory views, and capacity reports.

## Privileges

- Best experience: run as a DBA account or an account with `SELECT_CATALOG_ROLE` plus access to dynamic performance views.
- RAC-aware scripts use `GV$` views where useful.
- AWR/ASH/SQL history scripts may require the Oracle Diagnostics Pack license. Confirm licensing before using those views in production.

## Operational Notes

- Scripts are advisory diagnostics unless they contain explicit DDL or PL/SQL blocks.
- Review generated commands such as `ANALYZE TABLE ... VALIDATE STRUCTURE` before running them.
- Capacity and lifecycle repository scripts create local DBA-owned tables/views only when you run those setup scripts.
- Target baseline: Oracle Database 12c and newer. Some CDB, AWR, SQL Monitor, ASM, or plan-management scripts depend on licensed options or optional components.
