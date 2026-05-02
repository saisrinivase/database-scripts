# saisrinivase - MySQL Database Administration Scripts (360-Degree)

Purpose: Central, area-based SQL script repository for MySQL DBAs and engineers.

## Quick Start

1. Switch to this branch: `git checkout mysql`.
2. Pick an area folder based on the issue you are troubleshooting.
3. Run a script with `mysql`, for example: `mysql -u root -p < 00_environment/01_server_instance_overview.sql`.
4. Most scripts are read-only diagnostics. DDL/lab scripts include clear `CREATE`, `ALTER`, or `EVENT` statements and should be reviewed before execution.

## Scope

- Coverage: `39` operational areas.
- Current MySQL SQL scripts: `210`.
- Script style: every SQL file includes Purpose, Area, Usage, and Notes headers.
- Primary metadata used: `information_schema`, `performance_schema`, `sys`, selected `mysql` metadata, and InnoDB views.

## Area Index

- `00_environment` (3 scripts): MySQL server, version, plugin, component, and schema inventory.
- `01_database_size` (3 scripts): Schema, tablespace, table, and storage size diagnostics.
- `02_table_storage` (4 scripts): Table storage, row counts, fragmentation, and storage attributes.
- `03_index_analysis` (4 scripts): Index inventory, unused index candidates, duplicate indexes, and maintenance signals.
- `04_lob_blob_storage` (4 scripts): BLOB/TEXT/JSON footprint, large column inventory, and row format checks.
- `05_partitioning` (7 scripts): Partition inventory, partition sizing, partition index posture, and candidates.
- `06_activity_locks` (4 scripts): Active threads, blocking, metadata locks, waits, and long transactions.
- `07_table_fragmentation_reclaim` (5 scripts): Fragmentation estimates, OPTIMIZE candidates, purge pressure, and stale statistics.
- `08_replication_ha` (4 scripts): Replication, Group Replication, binary log generation, lag, and HA posture.
- `09_security_roles` (4 scripts): Users, roles, grants, default roles, passwords, and privilege exposure.
- `10_maintenance_monitoring` (5 scripts): InnoDB checkpoint, cache hit, top statements, variable drift, and connection capacity.
- `11_performance_tuning` (6 scripts): Top statements, latency, temp tables, I/O-heavy statements, variables, and routines.
- `12_planner_statistics` (6 scripts): Optimizer statistics, full scan hotspots, histograms, and optimizer variables.
- `13_io_redo_checkpoints` (7 scripts): File I/O, table/index I/O, binary log, redo, checkpoint, and temporary table pressure.
- `14_connection_workload` (6 scripts): Connection distribution, idle sessions, thread states, limits, and XA state.
- `15_capacity_forecasting` (8 scripts): Capacity snapshot repository, capture scripts, and growth reports.
- `16_internals_deep_dive` (6 scripts): Transactions, table files, dictionary size, dependencies, LOB storage, and purge profile.
- `17_execution_plans` (4 scripts): EXPLAIN prerequisites, EXPLAIN ANALYZE templates, generated plan commands, and red flags.
- `18_long_queries_full_scans` (4 scripts): Long-running statements and full table scan diagnostics.
- `19_dml_optimization` (4 scripts): Write-heavy tables, update pressure, foreign key indexes, and fragmentation.
- `20_design_matters` (4 scripts): Schema design risks such as missing primary keys, wide tables, over-indexing, and nullable-heavy tables.
- `21_configuration_parameters` (4 scripts): Core performance, redo/binlog, optimizer statistics, and connection variable baselines.
- `22_application_orm_performance` (4 scripts): ORM patterns, select-star risk, chatty SQL, parse pressure, and idle transactions.
- `23_functions_dynamic_sql` (4 scripts): Routine inventory, dynamic SQL, SQL SECURITY, and trigger diagnostics.
- `24_complex_filter_search` (4 scripts): LIKE, JSON, fulltext, spatial, and search index diagnostics.
- `25_oltp_olap_goals` (4 scripts): Workload classification and OLTP/OLAP pressure indicators.
- `26_physical_cloud_diagnostics` (4 scripts): Platform fingerprint, storage, wait, checkpoint, and cloud signals.
- `27_high_speed_tuning` (6 scripts): Fast triage dashboards, wait detail, missing indexes, and action queues.
- `27_mysql_health_validation` (9 scripts): MySQL health reports, sanity checks, and optional lab issue scripts.
- `28_sql_resource_attribution` (4 scripts): Statement resource attribution by digest, schema, account, and infrastructure tier.
- `29_object_inventory_health` (18 scripts): Deep object inventory for tables, keys, routines, triggers, grants, partitions, and external links.
- `30_backup_restore_pitr_dr` (5 scripts): Binary log, backup, PITR, replica, and disaster recovery evidence.
- `31_logging_error_signatures` (4 scripts): Error log, slow query digests, waits, locks, and deadlock indicators.
- `32_upgrade_patch_readiness` (6 scripts): Version, plugin, invalid/risky object, charset/collation, and upgrade readiness checks.
- `33_innodb_memory_pressure` (5 scripts): InnoDB checkpoint, redo, purge, parallelism, buffer pool, and temp pressure.
- `34_consistency_integrity_checks` (5 scripts): Invalid metadata, CHECK TABLE command generation, corruption indicators, and MVCC risks.
- `35_pooler_proxy_diagnostics` (5 scripts): Connection saturation, proxy patterns, prepared statement cache, and pooling risks.
- `36_cloud_provider_signals` (5 scripts): Managed-service fingerprints, variable drift, replica/failover, storage, and incident evidence.
- `37_object_lifecycle_capacity` (12 scripts): Object lifecycle repository, snapshots, advisory views, and capacity reporting.

## Privileges

- Best experience: run as an administrative user with read access to `performance_schema`, `information_schema`, `sys`, and selected `mysql` metadata tables.
- Enable `performance_schema` consumers/instruments for richer workload and wait diagnostics.
- For MySQL 5.7, some MySQL 8.0 features such as `EXPLAIN ANALYZE`, roles, histograms, and `performance_schema.error_log` may not exist.

## Operational Notes

- Scripts are advisory diagnostics unless they contain explicit DDL.
- Review generated commands such as `OPTIMIZE TABLE`, `CHECK TABLE`, or lifecycle repository DDL before production execution.
- Target baseline: MySQL 8.0 and newer, with many read-only scripts also useful on compatible MariaDB or MySQL 5.7 systems depending on view availability.
