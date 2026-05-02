# Oracle Performance Tuning Coverage

This document applies to the `oracle` branch.

## Script Areas

- `00_environment`: Oracle instance, database, option, and catalog inventory. (3 scripts)
- `01_database_size`: Database, tablespace, datafile, temp file, and segment size diagnostics. (11 scripts)
- `02_table_storage`: Table storage, segment allocation, row counts, and storage attributes. (4 scripts)
- `03_index_analysis`: Index storage, visibility, duplication, selectivity, and maintenance candidates. (4 scripts)
- `04_lob_blob_storage`: LOB/BLOB storage, SecureFiles, BasicFiles, compression, deduplication, and top LOB segments. (4 scripts)
- `05_partitioning`: Partitioned table, partition segment, indexing, and recommendation checks. (7 scripts)
- `06_activity_locks`: Active sessions, blockers, wait events, locks, and long-running transactions. (4 scripts)
- `07_segment_space_reclaim`: Segment space reclaim, stale statistics, undo retention, and Segment Advisor signals. (5 scripts)
- `08_replication_ha`: Data Guard, archivelog, redo generation, standby apply, and high availability posture. (10 scripts)
- `09_security_roles`: Users, roles, system privileges, object grants, profiles, and exposure checks. (4 scripts)
- `10_maintenance_monitoring`: DB writer, cache, checkpoint, top SQL, parameter drift, and capacity monitoring. (5 scripts)
- `11_performance_tuning`: Top SQL, temp-heavy SQL, I/O-heavy SQL, parameter tuning, and PL/SQL hotspots. (15 scripts)
- `12_planner_statistics`: Optimizer statistics quality, stale objects, histogram and extension inventory, and optimizer parameters. (10 scripts)
- `13_io_redo_checkpoints`: Datafile I/O, object I/O, redo, archiver, checkpoint, and temp pressure. (10 scripts)
- `14_connection_workload`: Session distribution, idle sessions, connection capacity, and distributed transaction status. (6 scripts)
- `15_capacity_forecasting`: Capacity snapshot repository, capture scripts, and growth reports. (12 scripts)
- `16_internals_deep_dive`: Undo, extents, segment internals, dependencies, LOB internals, and retention profiles. (6 scripts)
- `17_execution_plans`: Plan capture, DBMS_XPLAN templates, and plan red-flag candidates. (8 scripts)
- `18_long_queries_full_scans`: Long-running SQL and full scan workload diagnostics. (4 scripts)
- `19_dml_optimization`: Write-heavy tables, row movement, index support for foreign keys, and DML pressure. (4 scripts)
- `20_design_matters`: Schema design anti-patterns such as missing primary keys, wide tables, and high-null columns. (4 scripts)
- `21_configuration_parameters`: Oracle initialization parameter baselines for performance, redo, stats, and connections. (4 scripts)
- `22_application_orm_performance`: Application and ORM query patterns, select-star risk, chatty SQL, and idle transaction behavior. (4 scripts)
- `23_functions_dynamic_sql`: PL/SQL procedure/function execution, dynamic SQL, security definer analogs, and triggers. (4 scripts)
- `24_complex_filter_search`: LIKE, JSON, XML, Oracle Text, spatial, and domain index diagnostics. (4 scripts)
- `25_oltp_olap_goals`: Workload classification and OLTP/OLAP pressure indicators. (4 scripts)
- `26_physical_cloud_diagnostics`: Platform fingerprint, storage, wait, checkpoint, and managed-service signals. (4 scripts)
- `27_high_speed_tuning`: Fast triage dashboards and action queues for bottleneck diagnosis. (6 scripts)
- `27_oracle_health_validation`: Oracle health reports, sanity gates, and optional lab issue scripts. (9 scripts)
- `28_sql_resource_attribution`: SQL resource attribution by SQL ID, service, parsing schema, and infrastructure tier. (8 scripts)
- `29_object_inventory_health`: Deep object inventory and health checks for tables, indexes, constraints, PL/SQL, partitions, grants, DB links, and synonyms. (18 scripts)
- `30_backup_restore_pitr_dr`: RMAN, archivelog, restore point, PITR, and Data Guard evidence. (9 scripts)
- `31_logging_error_signatures`: ADR, alert log, trace, error signatures, slow SQL, lock waits, and deadlock indicators. (4 scripts)
- `32_upgrade_patch_readiness`: Version, component, SQL patch, invalid object, NLS, and post-upgrade regression checks. (6 scripts)
- `33_db_writer_memory_pressure`: DB writer, checkpoint, redo writer, stats jobs, parallel workers, SGA/PGA, and temp spill pressure. (5 scripts)
- `34_consistency_integrity_checks`: Invalid objects, corruption views, LOB dictionary signals, and validate-structure commands. (5 scripts)
- `35_pooler_proxy_diagnostics`: Connection saturation, session distribution, cursor cache, shared server, and proxy/client signals. (5 scripts)
- `36_cloud_provider_signals`: Managed-service fingerprints, parameter drift, replica lag/failover, and incident-window evidence. (7 scripts)
- `37_object_lifecycle_capacity`: Object lifecycle repository, DDL trigger, snapshots, advisory views, and capacity reports. (12 scripts)

## Notes

- Designed around Oracle Database 12c+ catalog and dynamic performance views.
- `DBA_HIST_*`, ASH, SQL Monitor, and similar history views may require Diagnostics Pack or Tuning Pack licensing.
- Use SQL*Plus or SQLcl for substitution variables and `DBMS_XPLAN` output.
