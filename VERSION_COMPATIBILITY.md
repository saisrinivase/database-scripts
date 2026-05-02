# MySQL Version Compatibility

This document applies to the `mysql` branch.

## Script Areas

- `00_environment`: MySQL server, version, plugin, component, and schema inventory. (3 scripts)
- `01_database_size`: Schema, tablespace, table, and storage size diagnostics. (3 scripts)
- `02_table_storage`: Table storage, row counts, fragmentation, and storage attributes. (4 scripts)
- `03_index_analysis`: Index inventory, unused index candidates, duplicate indexes, and maintenance signals. (4 scripts)
- `04_lob_blob_storage`: BLOB/TEXT/JSON footprint, large column inventory, and row format checks. (4 scripts)
- `05_partitioning`: Partition inventory, partition sizing, partition index posture, and candidates. (7 scripts)
- `06_activity_locks`: Active threads, blocking, metadata locks, waits, and long transactions. (4 scripts)
- `07_table_fragmentation_reclaim`: Fragmentation estimates, OPTIMIZE candidates, purge pressure, and stale statistics. (5 scripts)
- `08_replication_ha`: Replication, Group Replication, binary log generation, lag, and HA posture. (4 scripts)
- `09_security_roles`: Users, roles, grants, default roles, passwords, and privilege exposure. (4 scripts)
- `10_maintenance_monitoring`: InnoDB checkpoint, cache hit, top statements, variable drift, and connection capacity. (5 scripts)
- `11_performance_tuning`: Top statements, latency, temp tables, I/O-heavy statements, variables, and routines. (6 scripts)
- `12_planner_statistics`: Optimizer statistics, full scan hotspots, histograms, and optimizer variables. (6 scripts)
- `13_io_redo_checkpoints`: File I/O, table/index I/O, binary log, redo, checkpoint, and temporary table pressure. (7 scripts)
- `14_connection_workload`: Connection distribution, idle sessions, thread states, limits, and XA state. (6 scripts)
- `15_capacity_forecasting`: Capacity snapshot repository, capture scripts, and growth reports. (8 scripts)
- `16_internals_deep_dive`: Transactions, table files, dictionary size, dependencies, LOB storage, and purge profile. (6 scripts)
- `17_execution_plans`: EXPLAIN prerequisites, EXPLAIN ANALYZE templates, generated plan commands, and red flags. (4 scripts)
- `18_long_queries_full_scans`: Long-running statements and full table scan diagnostics. (4 scripts)
- `19_dml_optimization`: Write-heavy tables, update pressure, foreign key indexes, and fragmentation. (4 scripts)
- `20_design_matters`: Schema design risks such as missing primary keys, wide tables, over-indexing, and nullable-heavy tables. (4 scripts)
- `21_configuration_parameters`: Core performance, redo/binlog, optimizer statistics, and connection variable baselines. (4 scripts)
- `22_application_orm_performance`: ORM patterns, select-star risk, chatty SQL, parse pressure, and idle transactions. (4 scripts)
- `23_functions_dynamic_sql`: Routine inventory, dynamic SQL, SQL SECURITY, and trigger diagnostics. (4 scripts)
- `24_complex_filter_search`: LIKE, JSON, fulltext, spatial, and search index diagnostics. (4 scripts)
- `25_oltp_olap_goals`: Workload classification and OLTP/OLAP pressure indicators. (4 scripts)
- `26_physical_cloud_diagnostics`: Platform fingerprint, storage, wait, checkpoint, and cloud signals. (4 scripts)
- `27_high_speed_tuning`: Fast triage dashboards, wait detail, missing indexes, and action queues. (6 scripts)
- `27_mysql_health_validation`: MySQL health reports, sanity checks, and optional lab issue scripts. (9 scripts)
- `28_sql_resource_attribution`: Statement resource attribution by digest, schema, account, and infrastructure tier. (4 scripts)
- `29_object_inventory_health`: Deep object inventory for tables, keys, routines, triggers, grants, partitions, and external links. (18 scripts)
- `30_backup_restore_pitr_dr`: Binary log, backup, PITR, replica, and disaster recovery evidence. (5 scripts)
- `31_logging_error_signatures`: Error log, slow query digests, waits, locks, and deadlock indicators. (4 scripts)
- `32_upgrade_patch_readiness`: Version, plugin, invalid/risky object, charset/collation, and upgrade readiness checks. (6 scripts)
- `33_innodb_memory_pressure`: InnoDB checkpoint, redo, purge, parallelism, buffer pool, and temp pressure. (5 scripts)
- `34_consistency_integrity_checks`: Invalid metadata, CHECK TABLE command generation, corruption indicators, and MVCC risks. (5 scripts)
- `35_pooler_proxy_diagnostics`: Connection saturation, proxy patterns, prepared statement cache, and pooling risks. (5 scripts)
- `36_cloud_provider_signals`: Managed-service fingerprints, variable drift, replica/failover, storage, and incident evidence. (5 scripts)
- `37_object_lifecycle_capacity`: Object lifecycle repository, snapshots, advisory views, and capacity reporting. (12 scripts)

## Notes

- Designed around MySQL 8.0 metadata and performance views.
- Some features require `performance_schema` instruments/consumers to be enabled.
- MySQL 5.7 and MariaDB compatibility varies by view and feature.
