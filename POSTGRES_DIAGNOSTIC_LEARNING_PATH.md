# PostgreSQL Diagnostic Learning Path

Purpose: Provide a beginner-to-pro structure for diagnosing PostgreSQL issues with this repository. Use this as the starting map when you know the symptom but not the internal keyword yet.

## How To Use This Path

1. Start with the first-pass dashboards to identify the dominant pressure area.
2. Follow the symptom route to the focused script group.
3. Use the pro keyword map when the issue needs internals-level diagnosis.
4. Capture before/after evidence when you change settings, indexes, SQL, vacuum strategy, or storage.

## Level 1: Baseline And Environment

Goal: Know what server, database, extensions, settings, and catalog footprint you are diagnosing.

| Question | Primary scripts |
| --- | --- |
| What PostgreSQL version, uptime, database, and core settings am I on? | `00_environment/01_server_instance_overview.sql` |
| What extensions are installed and what is missing? | `00_environment/02_extensions_installed.sql`, `16_internals_deep_dive/11_internal_extension_readiness.sql` |
| What objects exist in this database? | `00_environment/03_database_catalog_overview.sql`, `29_object_inventory_health/01_object_type_inventory.sql` |
| Which settings differ from defaults? | `10_maintenance_monitoring/04_non_default_config.sql`, `21_configuration_parameters/05_parameter_deviation_necessity_report.sql` |

## Level 2: First-Pass Incident Dashboard

Goal: Quickly answer whether the issue is locks, waits, SQL, IO, WAL, vacuum, replication, connection pressure, or capacity.

| Symptom | Start here | Then run |
| --- | --- | --- |
| General slowness, unknown cause | `38_observability_360/01_instance_health_360_dashboard.sql` | `27_high_speed_tuning/01_bottleneck_overview_dashboard.sql` |
| Need CloudWatch-style SQL-visible metrics | `38_observability_360/02_cloudwatch_metric_equivalents.sql` | `38_observability_360/03_stat_view_coverage_check.sql` |
| Need immediate action queue | `39_observer_agent_monitoring/04_active_incident_detector.sql` | `39_observer_agent_monitoring/06_top_root_cause_action_queue.sql` |
| pgAdmin copy/paste workflow | `40_pgadmin_safe_diagnostics/01_pgadmin_compatibility_audit.sql` | Pick the matching `40_pgadmin_safe_diagnostics/*` script |
| Symptom is known but subsystem is unclear | `42_problem_identification_internals/01_symptom_to_subsystem_router.sql` | Run the focused script returned by the router |

## Level 3: Core Troubleshooting Routes

### Locks, Waits, And Sessions

| Diagnostic question | Scripts |
| --- | --- |
| Who is active and what are they waiting on? | `06_activity_locks/01_active_sessions.sql`, `06_activity_locks/04_wait_events_summary.sql` |
| Who is blocking whom? | `06_activity_locks/02_blocking_and_blocked_sessions.sql`, `27_high_speed_tuning/02_waits_and_blocking_details.sql` |
| Are long transactions hurting vacuum or concurrency? | `06_activity_locks/03_long_running_transactions.sql`, `14_connection_workload/02_idle_in_transaction_risk.sql` |
| What internal subsystem does the wait point to? | `16_internals_deep_dive/10_wait_event_internals_live_map.sql` |
| Are advisory, predicate, transaction, or fast-path locks involved? | `42_problem_identification_internals/02_lock_manager_full_diagnosis.sql` |

### Query Performance

| Diagnostic question | Scripts |
| --- | --- |
| Which SQL consumes most total time? | `10_maintenance_monitoring/03_top_statements_pg_stat_statements.sql`, `11_performance_tuning/01_top_queries_by_total_exec_time.sql` |
| Which SQL is CPU-like? | `11_performance_tuning/07_top_10_cpu_intensive_queries_pgadmin.sql`, `28_pgss_resource_attribution/01_pgss_query_resource_percent.sql` |
| Which SQL spills to temp disk? | `11_performance_tuning/08_top_10_temp_disk_spill_queries_pgadmin.sql`, `33_bgwriter_memory_pressure/05_temp_spill_work_mem_pressure.sql` |
| Which SQL is IO-heavy? | `11_performance_tuning/04_io_bound_query_candidates.sql`, `13_io_wal_checkpoints/01_database_io_profile.sql` |
| Which currently running SQL is hurting now? | `11_performance_tuning/10_active_top_10_runtime_pressure_pgadmin.sql`, `18_long_queries_full_scans/01_active_long_queries.sql` |

### Planner, Indexes, And Execution Plans

| Diagnostic question | Scripts |
| --- | --- |
| Are stats stale? | `12_planner_statistics/01_tables_needing_analyze.sql`, `12_planner_statistics/05_autovacuum_analyze_settings_by_table.sql` |
| Are sequential scans a problem? | `12_planner_statistics/02_seq_scan_hotspots.sql`, `18_long_queries_full_scans/04_full_scan_hotspot_tables.sql` |
| Are extended stats needed? | `12_planner_statistics/04_extended_stats_candidates.sql` |
| Are indexes unused, duplicate, or missing? | `03_index_analysis/02_unused_indexes_candidates.sql`, `03_index_analysis/03_duplicate_indexes.sql`, `27_high_speed_tuning/03_missing_index_candidates_from_scan_pressure.sql` |
| What plan evidence should I gather? | `17_execution_plans/01_plan_capture_prerequisites.sql`, `17_execution_plans/03_generate_explain_for_top_queries.sql`, `17_execution_plans/04_plan_red_flag_candidates.sql` |

### Vacuum, Bloat, Freeze, And Wraparound

| Diagnostic question | Scripts |
| --- | --- |
| Which tables look bloated? | `07_vacuum_bloat/01_table_bloat_estimate.sql`, `07_vacuum_bloat/04_dead_tuples_hotspots.sql` |
| Is autovacuum keeping up? | `07_vacuum_bloat/02_autovacuum_table_status.sql`, `33_bgwriter_memory_pressure/03_autovacuum_worker_pressure.sql` |
| Is freeze or XID age risky? | `07_vacuum_bloat/03_freeze_age_risk.sql`, `16_internals_deep_dive/01_database_xid_multixact_age.sql` |
| What is VACUUM doing right now? | `07_vacuum_bloat/05_vacuum_progress.sql`, `38_observability_360/08_autovacuum_vacuum_analyze_progress.sql` |
| What are the visibility/freezing internals? | `16_internals_deep_dive/06_visibility_and_freeze_profile.sql`, `16_internals_deep_dive/09_slru_control_checkpoint_internals.sql` |

### IO, WAL, Checkpoints, And Cloud Storage

| Diagnostic question | Scripts |
| --- | --- |
| Is this read/write IO pressure? | `13_io_wal_checkpoints/01_database_io_profile.sql`, `13_io_wal_checkpoints/07_pg_stat_io_overview_pg16_plus.sql` |
| Which tables or indexes cause IO? | `13_io_wal_checkpoints/02_table_io_hotspots.sql`, `13_io_wal_checkpoints/03_index_io_hotspots.sql` |
| Are checkpoints too frequent or expensive? | `10_maintenance_monitoring/01_bgwriter_checkpoint_stats.sql`, `13_io_wal_checkpoints/05_checkpoint_pressure_indicators.sql` |
| Is WAL/archive failing or too heavy? | `13_io_wal_checkpoints/04_wal_archiver_health.sql`, `33_bgwriter_memory_pressure/02_wal_writer_archiver_pressure.sql` |
| Is this a managed cloud/storage issue? | `26_physical_cloud_diagnostics/02_io_latency_profile.sql`, `36_cloud_provider_signals/04_storage_iops_temp_wal_pressure.sql` |

### Storage, TOAST, LOB, And Capacity

| Diagnostic question | Scripts |
| --- | --- |
| Which databases, tablespaces, and tables are largest? | `01_database_size/01_databases_size.sql`, `01_database_size/03_tablespaces_size.sql`, `02_table_storage/02_top_largest_tables.sql` |
| How much is heap vs index vs TOAST? | `02_table_storage/01_table_size_breakdown.sql`, `16_internals_deep_dive/05_fsm_vm_toast_size_breakdown.sql` |
| Which TOAST columns or compression policies matter? | `04_toast_lob_blob/01_tables_with_toast.sql`, `16_internals_deep_dive/07_toast_compression_storage_policy.sql` |
| Are large objects growing? | `04_toast_lob_blob/03_large_objects_summary.sql`, `04_toast_lob_blob/04_top_large_objects.sql` |
| How do I trend growth? | `15_capacity_forecasting/01_create_capacity_repository.sql`, `15_capacity_forecasting/07_database_growth_report.sql`, `37_object_lifecycle_capacity/10_monthly_capacity_report.sql` |

### Replication, HA, Backup, And DR

| Diagnostic question | Scripts |
| --- | --- |
| What is replication lag? | `08_replication_ha/01_primary_replication_status.sql`, `08_replication_ha/02_standby_replay_status.sql` |
| Are slots retaining WAL? | `08_replication_ha/03_replication_slots_health.sql`, `26_physical_cloud_diagnostics/04_replication_slot_wal_retention_risk.sql` |
| Is archive/PITR configured and healthy? | `30_backup_restore_pitr_dr/01_backup_pitr_configuration_health.sql`, `30_backup_restore_pitr_dr/02_wal_archiving_gap_and_lag.sql` |
| Do we have restore evidence? | `30_backup_restore_pitr_dr/03_restore_to_timestamp_quick_test.sql`, `30_backup_restore_pitr_dr/05_backup_restore_evidence_contract.sql` |
| What are RPO/RTO signals? | `30_backup_restore_pitr_dr/04_dr_rto_rpo_replication_evidence.sql`, `36_cloud_provider_signals/03_replica_lag_failover_signals.sql` |
| Is logical replication or CDC stopped, lagging, or retaining WAL? | `42_problem_identification_internals/03_logical_replication_cdc_health.sql` |

## Level 4: Pro Internals Keyword Map

Use these when the basic symptom route points to PostgreSQL internals.

| Keyword | What it explains | Primary script |
| --- | --- | --- |
| TOAST | out-of-line values, compression, wide-row storage | `16_internals_deep_dive/07_toast_compression_storage_policy.sql` |
| FSM | free space map, update/delete churn, bloat signals | `16_internals_deep_dive/08_relation_forks_persistence_map.sql` |
| VM | visibility map, index-only scan quality, freeze coverage | `16_internals_deep_dive/06_visibility_and_freeze_profile.sql` |
| relfilenode | logical-to-physical storage mapping | `16_internals_deep_dive/02_relation_filenode_mapping.sql` |
| SLRU | transaction, subtransaction, multixact internal IO | `16_internals_deep_dive/09_slru_control_checkpoint_internals.sql` |
| XID/multixact | wraparound and shared-lock aging risk | `16_internals_deep_dive/01_database_xid_multixact_age.sql` |
| LWLock/wait_event | internal contention route to lock, WAL, buffer, IO, IPC | `16_internals_deep_dive/10_wait_event_internals_live_map.sql` |
| pg_stat_io | backend/object/context IO attribution | `13_io_wal_checkpoints/07_pg_stat_io_overview_pg16_plus.sql` |
| pg_backend_memory_contexts | current backend memory context shape | `16_internals_deep_dive/12_backend_memory_contexts_snapshot.sql` |
| autovacuum internals | triggers, worker saturation, blockers, freeze pressure, and running phases | `16_internals_deep_dive/14_vacuum_internal_pressure_dashboard.sql` |
| WAL write path | generation, WAL buffers, write/sync, archive, slots, and live waits | `16_internals_deep_dive/15_wal_write_path_pressure_dashboard.sql` |
| checkpoint/bgwriter | requested checkpoints, write/sync duration, buffer cleaning, and backend fallback | `16_internals_deep_dive/16_checkpoint_background_writer_pressure_15_plus.sql` |
| cloud portability | available SQL diagnostics, privilege gaps, and provider-only metrics | `16_internals_deep_dive/17_cloud_portability_capability_matrix.sql` |
| AWS CloudWatch alarm | exact RDS/Aurora PostgreSQL metric name to deep-dive SQL or AWS-only path | `41_aws_rds_aurora_postgresql/01_cloudwatch_metric_deep_dive_router.sql` |
| DBLoad/DBLoadNonCPU | Database Insights AAS split by CPU, waits, SQL, user, application, and host | `41_aws_rds_aurora_postgresql/10_database_insights_dbload_deep_dive.sql` |
| DiskQueueDepth | AWS queue metric correlated with PostgreSQL I/O waits, latency, WAL, temp, and workload | `41_aws_rds_aurora_postgresql/11_disk_queue_depth_deep_dive.sql` |
| BufferCacheHitRatio/ReadIOPS/WriteIOPS | cache attribution and a short PostgreSQL I/O rate sample | `41_aws_rds_aurora_postgresql/12_buffer_cache_read_write_iops_deep_dive.sql` |
| SQL text truncation | server capture limit, hidden query text, query ID, and pg_stat_statements readiness | `16_internals_deep_dive/18_query_text_capture_limits.sql` |
| pageinspect/amcheck/pg_visibility | deep inspection extension readiness | `16_internals_deep_dive/11_internal_extension_readiness.sql` |
| full keyword coverage | searchable keyword-to-script map | `16_internals_deep_dive/13_postgres_internals_keyword_coverage_matrix.sql` |

## Level 5: Repeatable Observer Workflow

Goal: Move from one-time diagnosis to repeatable monitoring.

1. Create observer repository: `39_observer_agent_monitoring/01_create_observer_repository.sql`
2. Capture snapshots: `39_observer_agent_monitoring/02_capture_observer_snapshot.sql`
3. Review health: `39_observer_agent_monitoring/03_health_score_dashboard.sql`
4. Detect incidents: `39_observer_agent_monitoring/04_active_incident_detector.sql`
5. Classify pressure: `39_observer_agent_monitoring/05_wait_lock_io_wal_classifier.sql`
6. Queue actions: `39_observer_agent_monitoring/06_top_root_cause_action_queue.sql`
7. Track drift: `39_observer_agent_monitoring/07_baseline_deviation_report.sql`

## Validation Standard

- Scripts should run in `psql` and pgAdmin unless they intentionally create lab/repository objects.
- Scripts should use only plain SQL or server-side PL/pgSQL, not psql-only branching.
- Each diagnostic should explain purpose, output, risk, and next action.
- For any production change, capture evidence before and after with the same script.
