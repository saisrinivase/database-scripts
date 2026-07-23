# Internals Coverage Matrix

Purpose: Map administration topics to PostgreSQL internals sources and ready-to-run scripts.

## Topic Coverage

| Topic | Core Internals Sources | Primary Scripts |
|---|---|---|
| Instance baseline | `version()`, `pg_postmaster_start_time()`, `pg_settings` | `00_environment/01_server_instance_overview.sql` |
| Extension baseline | `pg_extension`, `pg_namespace` | `00_environment/02_extensions_installed.sql` |
| Catalog object footprint | `pg_class`, `pg_namespace` | `00_environment/03_database_catalog_overview.sql`, `16_internals_deep_dive/03_system_catalog_size_profile.sql` |
| Database size | `pg_database`, `pg_database_size()` | `01_database_size/01_databases_size.sql` |
| Tablespace size | `pg_tablespace`, `pg_tablespace_size()` | `01_database_size/03_tablespaces_size.sql` |
| Table/index/TOAST composition | `pg_class`, `pg_relation_size()`, `pg_indexes_size()` | `02_table_storage/01_table_size_breakdown.sql`, `16_internals_deep_dive/05_fsm_vm_toast_size_breakdown.sql` |
| Index usage/utilization | `pg_stat_user_indexes`, `pg_index` | `03_index_analysis/01_index_size_and_usage.sql`, `03_index_analysis/02_unused_indexes_candidates.sql` |
| Duplicate index internals | `pg_index` metadata vectors | `03_index_analysis/03_duplicate_indexes.sql` |
| TOAST internals | `pg_class.reltoastrelid`, `pg_attribute.attstorage`, `pg_attribute.attcompression` | `04_toast_lob_blob/01_tables_with_toast.sql`, `04_toast_lob_blob/02_toast_heavy_tables.sql`, `16_internals_deep_dive/07_toast_compression_storage_policy.sql` |
| Large object (BLOB/LOB) footprint | `pg_largeobject` | `04_toast_lob_blob/03_large_objects_summary.sql`, `04_toast_lob_blob/04_top_large_objects.sql` |
| Partition metadata | `pg_inherits`, `pg_get_partkeydef()` | `05_partitioning/01_partitioned_tables_overview.sql` |
| Session/lock internals | `pg_stat_activity`, `pg_blocking_pids()` | `06_activity_locks/01_active_sessions.sql`, `06_activity_locks/02_blocking_and_blocked_sessions.sql` |
| 360 observability dashboard | `pg_stat_activity`, `pg_locks`, `pg_stat_database`, `pg_stat_wal`, `pg_stat_bgwriter`, `pg_stat_checkpointer`, `pg_stat_replication` | `38_observability_360/01_instance_health_360_dashboard.sql` |
| CloudWatch metric equivalents | SQL-visible stats plus provider/OS-only gap classification | `38_observability_360/02_cloudwatch_metric_equivalents.sql` |
| Observer-agent repository | `dba_observer.observer_snapshots`, `dba_observer.observer_findings`, `dba_observer.observer_metric_thresholds` | `39_observer_agent_monitoring/01_create_observer_repository.sql`, `39_observer_agent_monitoring/02_capture_observer_snapshot.sql` |
| Vacuum/bloat internals | `pg_stat_user_tables`, table reloptions, `relfrozenxid`, `backend_xmin`, `pg_stat_progress_vacuum` | `16_internals_deep_dive/14_vacuum_internal_pressure_dashboard.sql`, `07_vacuum_bloat/01_table_bloat_estimate.sql`, `07_vacuum_bloat/03_freeze_age_risk.sql` |
| Replication state | `pg_stat_replication`, `pg_is_in_recovery()` | `08_replication_ha/01_primary_replication_status.sql`, `08_replication_ha/02_standby_replay_status.sql` |
| Replication slot retention | `pg_replication_slots`, LSN diff functions | `08_replication_ha/03_replication_slots_health.sql` |
| WAL internals | `pg_stat_wal`, `pg_stat_archiver`, `pg_replication_slots`, WAL waits, LSN functions | `16_internals_deep_dive/15_wal_write_path_pressure_dashboard.sql`, `08_replication_ha/04_wal_generation_rate.sql`, `13_io_wal_checkpoints/04_wal_archiver_health.sql` |
| Security/privilege internals | `pg_roles`, `pg_auth_members`, `pg_default_acl`, `information_schema` | `09_security_roles/*.sql` |
| Checkpoints and writer internals | `pg_stat_bgwriter`, `pg_stat_checkpointer`, write-path waits, `pg_control_checkpoint()` | `16_internals_deep_dive/16_checkpoint_background_writer_pressure_15_plus.sql`, `10_maintenance_monitoring/01_bgwriter_checkpoint_stats.sql`, `16_internals_deep_dive/09_slru_control_checkpoint_internals.sql` |
| Query-level performance | `pg_stat_statements`, `pg_stat_user_functions` | `11_performance_tuning/*.sql` |
| Planner stats health | `pg_stat_user_tables`, `pg_stats`, `pg_statistic_ext` | `12_planner_statistics/*.sql` |
| I/O internals | `pg_stat_database`, `pg_statio_*`, `pg_stat_io` | `13_io_wal_checkpoints/*.sql` |
| Connection behavior internals | `pg_stat_activity`, `pg_roles`, `pg_prepared_xacts` | `14_connection_workload/*.sql` |
| Capacity trend internals | Snapshot tables + runtime stats views | `15_capacity_forecasting/*.sql` |
| XID/multixact aging | `pg_database.datfrozenxid`, `datminmxid`, `pg_class.relfrozenxid` | `16_internals_deep_dive/01_database_xid_multixact_age.sql`, `16_internals_deep_dive/06_visibility_and_freeze_profile.sql` |
| Storage file mapping and forks | `pg_relation_filenode()`, `pg_relation_filepath()`, `pg_relation_size(..., fork)` | `16_internals_deep_dive/02_relation_filenode_mapping.sql`, `16_internals_deep_dive/08_relation_forks_persistence_map.sql` |
| SLRU internals | `pg_stat_slru`, `pg_control_checkpoint()` | `16_internals_deep_dive/09_slru_control_checkpoint_internals.sql` |
| Wait-event internals | `pg_stat_activity.wait_event_type`, `pg_stat_activity.wait_event` | `16_internals_deep_dive/10_wait_event_internals_live_map.sql`, `38_observability_360/04_wait_event_hotspots.sql` |
| Inspection extension readiness | `pg_available_extensions`, `pg_extension` | `16_internals_deep_dive/11_internal_extension_readiness.sql` |
| Backend memory internals | `pg_backend_memory_contexts`, `pg_stat_activity` | `16_internals_deep_dive/12_backend_memory_contexts_snapshot.sql` |
| Internals keyword routing | Repository keyword map | `16_internals_deep_dive/13_postgres_internals_keyword_coverage_matrix.sql`, `POSTGRES_DIAGNOSTIC_LEARNING_PATH.md` |
| Cloud and managed-service portability | catalog capability detection, role membership, version gates, provider-only metric classification | `16_internals_deep_dive/17_cloud_portability_capability_matrix.sql`, `38_observability_360/02_cloudwatch_metric_equivalents.sql` |
| AWS RDS/Aurora CloudWatch metrics | 83 unique PostgreSQL-applicable metrics across compute, memory, storage, WAL, replication, XID, backup, serverless, and network | `41_aws_rds_aurora_postgresql/01_cloudwatch_metric_deep_dive_router.sql`, `41_aws_rds_aurora_postgresql/*.sql` |
| Query text capture and truncation | `track_activity_query_size`, `track_activities`, `compute_query_id`, role visibility, `pg_stat_statements` readiness | `16_internals_deep_dive/18_query_text_capture_limits.sql` |
| Dependency graph internals | `pg_depend` | `16_internals_deep_dive/04_dependency_fanout_objects.sql` |
| Object type inventory | `pg_class`, `pg_proc`, `pg_type`, `pg_tablespace`, `pg_trigger`, `information_schema.*` | `29_object_inventory_health/01_object_type_inventory.sql` |
| PK/FK and join-index health | `pg_constraint`, `pg_index`, `pg_stat_user_tables`, `pg_attribute` | `29_object_inventory_health/02_table_pk_fk_health.sql`, `29_object_inventory_health/04_missing_fk_supporting_indexes.sql`, `29_object_inventory_health/05_missing_join_column_indexes.sql` |
| Identifier naming and migration mapping | `pg_class`, `pg_attribute`, `pg_proc`, `pg_namespace` | `29_object_inventory_health/06_identifier_casing_risks.sql`, `29_object_inventory_health/15_oracle_package_synonym_mapping.sql` |
| Ingest/federation/object query diagnostics | `pg_stat_progress_copy`, `pg_foreign_*`, `pg_stat_statements` | `29_object_inventory_health/13_insert_copy_activity.sql`, `29_object_inventory_health/14_fdw_inventory.sql`, `29_object_inventory_health/18_object_query_hotspots_pgss.sql` |

## Gaps to Expand Next

- Host/cloud-only metrics still need CloudWatch, OS tools, managed-service APIs, or monitoring agents for CPU, free memory, disk queue depth, network throughput, and free filesystem space.
- Per-application service-level dashboards can be expanded further when application naming conventions and latency/error budgets are known.
