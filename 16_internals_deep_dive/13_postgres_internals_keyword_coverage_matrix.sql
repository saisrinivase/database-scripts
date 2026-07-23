/*
PostgreSQL DBA Script: PostgreSQL Internals Keyword Coverage Matrix
Purpose: Provide a searchable map from PostgreSQL internals keywords to the best diagnostic scripts in this repository.
Area: Internals Deep Dive
Usage: Search this output by keyword during incidents: TOAST, VM, FSM, SLRU, XID, WAL, checkpoint, wait event, planner, bloat, replication, memory.
Sample Output: Columns include keyword, subsystem, primary_script, supporting_scripts, coverage_goal.
Notes: Read-only reference matrix. Keep updated whenever internals diagnostics are added.
*/
SELECT *
FROM (VALUES
    ('TOAST', 'storage_internals', '16_internals_deep_dive/07_toast_compression_storage_policy.sql', '04_toast_lob_blob/01_tables_with_toast.sql; 04_toast_lob_blob/02_toast_heavy_tables.sql', 'Find wide-row storage, compression policy, and TOAST-heavy tables.'),
    ('LOB/BLOB/large object', 'storage_internals', '04_toast_lob_blob/03_large_objects_summary.sql', '04_toast_lob_blob/04_top_large_objects.sql', 'Inventory pg_largeobject usage and largest objects.'),
    ('FSM free space map', 'storage_forks', '16_internals_deep_dive/08_relation_forks_persistence_map.sql', '16_internals_deep_dive/05_fsm_vm_toast_size_breakdown.sql', 'Explain free-space-map size and churn/bloat symptoms.'),
    ('VM visibility map', 'vacuum_visibility', '16_internals_deep_dive/06_visibility_and_freeze_profile.sql', '16_internals_deep_dive/08_relation_forks_persistence_map.sql; 07_vacuum_bloat/03_freeze_age_risk.sql', 'Understand all-visible/all-frozen effects and freeze risk.'),
    ('relfilenode/relation filepath', 'storage_mapping', '16_internals_deep_dive/02_relation_filenode_mapping.sql', '16_internals_deep_dive/08_relation_forks_persistence_map.sql', 'Map logical relations to physical files and forks.'),
    ('SLRU', 'transaction_internals', '16_internals_deep_dive/09_slru_control_checkpoint_internals.sql', '16_internals_deep_dive/01_database_xid_multixact_age.sql', 'Diagnose Xact, Subtrans, MultiXact, Notify, and CommitTs pressure.'),
    ('XID wraparound', 'transaction_internals', '16_internals_deep_dive/01_database_xid_multixact_age.sql', '07_vacuum_bloat/03_freeze_age_risk.sql; 16_internals_deep_dive/09_slru_control_checkpoint_internals.sql', 'Find database/table age risk before wraparound outage.'),
    ('multixact', 'transaction_internals', '16_internals_deep_dive/01_database_xid_multixact_age.sql', '16_internals_deep_dive/09_slru_control_checkpoint_internals.sql', 'Review shared-lock and foreign-key multixact age pressure.'),
    ('wait_event/LWLock/Lock/IO', 'wait_internals', '16_internals_deep_dive/10_wait_event_internals_live_map.sql', '38_observability_360/04_wait_event_hotspots.sql; 06_activity_locks/02_blocking_and_blocked_sessions.sql', 'Route live waits to lock, IO, WAL, client, IPC, or CPU next steps.'),
    ('shared buffers/cache', 'memory_io', '10_maintenance_monitoring/02_cache_hit_ratio.sql', '16_internals_deep_dive/11_internal_extension_readiness.sql; 33_bgwriter_memory_pressure/01_bgwriter_checkpointer_pressure.sql', 'Analyze cache hit, buffer residency readiness, and bgwriter pressure.'),
    ('backend memory/work_mem', 'memory_internals', '16_internals_deep_dive/12_backend_memory_contexts_snapshot.sql', '33_bgwriter_memory_pressure/05_temp_spill_work_mem_pressure.sql; 11_performance_tuning/09_top_10_memory_pressure_queries_pgadmin.sql', 'Connect memory context shape, temp spills, and SQL memory pressure.'),
    ('WAL', 'wal_internals', '16_internals_deep_dive/15_wal_write_path_pressure_dashboard.sql', '13_io_wal_checkpoints/04_wal_archiver_health.sql; 33_bgwriter_memory_pressure/02_wal_writer_archiver_pressure.sql; 38_observability_360/07_wal_checkpoint_archiver_dashboard.sql', 'Track WAL generation, archiver failures, WAL buffers, write/sync pressure, slots, and live waits.'),
    ('checkpoint/bgwriter/checkpointer', 'write_path', '16_internals_deep_dive/16_checkpoint_background_writer_pressure_15_plus.sql', '10_maintenance_monitoring/01_bgwriter_checkpoint_stats.sql; 13_io_wal_checkpoints/05_checkpoint_pressure_indicators.sql; 26_physical_cloud_diagnostics/03_checkpoint_fsync_pressure.sql', 'Diagnose checkpoint frequency, sync/write time, dirty buffers, background cleaning, and backend writes.'),
    ('pg_stat_io', 'io_internals', '13_io_wal_checkpoints/07_pg_stat_io_overview_pg16_plus.sql', '38_observability_360/02_cloudwatch_metric_equivalents.sql; 36_cloud_provider_signals/04_storage_iops_temp_wal_pressure.sql', 'Break down IO by backend/object/context and map to cloud storage symptoms.'),
    ('autovacuum/vacuum freeze', 'maintenance_internals', '16_internals_deep_dive/14_vacuum_internal_pressure_dashboard.sql', '07_vacuum_bloat/05_vacuum_progress.sql; 33_bgwriter_memory_pressure/03_autovacuum_worker_pressure.sql; 07_vacuum_bloat/04_dead_tuples_hotspots.sql', 'Find trigger breaches, cleanup blockers, running progress, worker saturation, dead tuples, and freeze risk.'),
    ('bloat/dead tuples', 'storage_health', '07_vacuum_bloat/01_table_bloat_estimate.sql', '07_vacuum_bloat/04_dead_tuples_hotspots.sql; 03_index_analysis/04_index_maintenance_candidates.sql', 'Estimate bloat and prioritize vacuum/reindex/table rewrite action.'),
    ('planner/stats/selectivity', 'planner_internals', '12_planner_statistics/01_tables_needing_analyze.sql', '12_planner_statistics/02_seq_scan_hotspots.sql; 12_planner_statistics/04_extended_stats_candidates.sql', 'Find stale stats, bad estimates, missing extended stats, and seq scan hotspots.'),
    ('pg_stat_statements/top SQL', 'query_attribution', '10_maintenance_monitoring/03_top_statements_pg_stat_statements.sql', '28_pgss_resource_attribution/01_pgss_query_resource_percent.sql; 38_observability_360/10_query_capture_quality_pgss.sql', 'Rank CPU/time/IO/temp/WAL SQL and verify capture quality.'),
    ('replication slot lag', 'replication_internals', '08_replication_ha/03_replication_slots_health.sql', '38_observability_360/09_replication_and_slot_dashboard.sql; 36_cloud_provider_signals/03_replica_lag_failover_signals.sql', 'Find WAL retention, replay lag, inactive slots, and failover RPO/RTO symptoms.'),
    ('catalog/dependency', 'catalog_internals', '16_internals_deep_dive/03_system_catalog_size_profile.sql', '16_internals_deep_dive/04_dependency_fanout_objects.sql', 'Inspect catalog growth and object dependency blast radius.'),
    ('amcheck/pageinspect/pg_visibility/pgstattuple', 'inspection_extensions', '16_internals_deep_dive/11_internal_extension_readiness.sql', '34_consistency_integrity_checks/04_amcheck_readiness_and_candidate_commands.sql', 'Know which deeper page, bloat, visibility, and corruption checks are available.'),
    ('RDS/Aurora/Cloud SQL/AlloyDB/Azure', 'cloud_portability', '16_internals_deep_dive/17_cloud_portability_capability_matrix.sql', '38_observability_360/02_cloudwatch_metric_equivalents.sql; 36_cloud_provider_signals/01_managed_service_fingerprint.sql', 'Identify SQL-visible metrics, privilege gaps, version gates, and provider-only host metrics.'),
    ('query text truncation/track_activity_query_size', 'query_capture', '16_internals_deep_dive/18_query_text_capture_limits.sql', '38_observability_360/10_query_capture_quality_pgss.sql; 40_pgadmin_safe_diagnostics/05_pgadmin_safe_pg_stat_statements_quality.sql', 'Separate script display, PostgreSQL capture limits, privilege redaction, and pg_stat_statements readiness.')
) AS coverage(keyword, subsystem, primary_script, supporting_scripts, coverage_goal)
ORDER BY subsystem, keyword;

-- SAMPLE_OUTPUT_BEGIN
-- keyword | subsystem | primary_script | coverage_goal
-- TOAST   | storage_internals | 16_internals_deep_dive/07_toast_compression_storage_policy.sql | Find wide-row storage...
-- SAMPLE_OUTPUT_END
