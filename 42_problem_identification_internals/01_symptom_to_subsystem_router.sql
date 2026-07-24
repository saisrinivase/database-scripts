/*
PostgreSQL DBA Script: Symptom To Subsystem Router
Purpose: Convert an observed production symptom into the first evidence query and the correct PostgreSQL internals deep dive.
Area: Problem Identification and Internals
Usage: Run in pgAdmin or psql, then filter observed_symptom using the result grid.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only static router. Start with evidence, confirm the subsystem, and only then tune or change configuration.
*/
SELECT *
FROM (VALUES
    ('high_cpu', 'executor_or_planner', 'Top SQL time share, active runnable sessions, plan shape', '11_performance_tuning/07_top_10_cpu_intensive_queries_pgadmin.sql', 'Do not infer CPU from elapsed time alone; correlate with host CPU.'),
    ('low_freeable_memory', 'memory_and_concurrency', 'Connections, temp spills, work_mem multiplication, backend memory', '41_aws_rds_aurora_postgresql/02_compute_memory_serverless_pressure.sql', 'Cloud/OS memory is authoritative; SQL identifies demand contributors.'),
    ('high_read_iops_or_latency', 'buffer_and_storage_io', 'Physical reads, cache misses, pg_stat_io, scan pressure', '13_io_wal_checkpoints/07_pg_stat_io_overview_pg16_plus.sql', 'Separate cache misses, large scans, temp I/O, checkpoints, and storage latency.'),
    ('high_write_iops_or_latency', 'wal_checkpoint_and_heap_io', 'WAL writes, checkpoints, backend writes, temp writes', '16_internals_deep_dive/15_wal_write_path_pressure_dashboard.sql', 'Find which write path is dominant before changing checkpoint settings.'),
    ('temp_storage_growth', 'sort_hash_materialize', 'Query temp blocks, temp files, work_mem-sensitive operators', '11_performance_tuning/08_top_10_temp_disk_spill_queries_pgadmin.sql', 'Tune SQL and plan shape before globally increasing work_mem.'),
    ('connections_exhausted', 'connection_admission', 'Connection states, owners, applications, reserved capacity', '10_maintenance_monitoring/05_connection_capacity.sql', 'Distinguish useful concurrency from idle or abandoned sessions.'),
    ('blocking_or_lock_timeout', 'lock_manager', 'Waiters, blockers, lock mode, advisory/predicate locks', '42_problem_identification_internals/02_lock_manager_full_diagnosis.sql', 'Resolve the blocking transaction and application pattern before raising timeouts.'),
    ('serializable_failures', 'predicate_locking', 'SIReadLock footprint and predicate-lock settings', '42_problem_identification_internals/02_lock_manager_full_diagnosis.sql', 'Serialization failures require transaction retry logic; lock settings are secondary.'),
    ('replica_lag', 'wal_send_receive_replay', 'LSN gaps, replay delay, WAL generation, conflicts, slots', '41_aws_rds_aurora_postgresql/06_replication_slots_global_database_pressure.sql', 'Identify send, network, receive, write, flush, or replay delay.'),
    ('cdc_lag_or_stopped', 'logical_replication', 'Publication, subscription workers, slots, sync state, replica identity', '42_problem_identification_internals/03_logical_replication_cdc_health.sql', 'Check worker absence, retained WAL, replica identity, schema drift, and conflicts.'),
    ('wal_growth', 'wal_retention_or_generation', 'WAL rate, archive failures, slot retention, long transactions', '41_aws_rds_aurora_postgresql/05_wal_checkpoint_log_volume_pressure.sql', 'Separate generation rate from retention.'),
    ('transaction_id_age', 'mvcc_freeze', 'Database/table XID age, blockers, autovacuum capacity', '07_vacuum_bloat/03_freeze_age_risk.sql', 'Anti-wraparound risk is urgent even when query latency is normal.'),
    ('dead_tuple_or_bloat_growth', 'mvcc_vacuum', 'Dead tuple percentage, vacuum recency, thresholds, blockers', '16_internals_deep_dive/14_vacuum_internal_pressure_dashboard.sql', 'Find why cleanup is not keeping pace before scheduling manual VACUUM.'),
    ('query_plan_regression', 'planner_statistics', 'Estimate error, analyze recency, statistics target, plan nodes', '17_execution_plans/04_plan_red_flag_candidates.sql', 'Compare plans and statistics from the same parameter and data context.'),
    ('index_not_used', 'planner_index_costing', 'Selectivity, casts, functions, visibility, index validity and size', '03_index_analysis/01_index_size_and_usage.sql', 'An existing index is not proof that it is selective or usable for the predicate.'),
    ('partition_scan_too_large', 'partition_pruning', 'Pruning setting, bounds, default partition, leaf balance, index parity', '42_problem_identification_internals/04_partition_pruning_maintenance_health.sql', 'Validate with EXPLAIN and Subplans Removed for the exact predicate.'),
    ('extension_job_or_feature_failure', 'extension_runtime', 'Installation, preload, jobs/workers, extension-owned catalogs', '42_problem_identification_internals/05_extension_runtime_health.sql', 'Extension health is capability-specific and must degrade safely when absent.'),
    ('pg18_io_underperforming', 'asynchronous_io', 'I/O method, concurrency, combine limits, pg_stat_io bytes/timing', '42_problem_identification_internals/06_pg18_async_io_readiness.sql', 'Compare workload evidence before and after I/O configuration changes.'),
    ('permission_or_rls_surprise', 'row_level_security', 'RLS enable/force state, policies, commands, roles, BYPASSRLS', '42_problem_identification_internals/07_row_level_security_policy_health.sql', 'Test with the actual application role; owners and BYPASSRLS roles behave differently.'),
    ('database_or_table_growth', 'capacity_and_object_storage', 'Heap, auxiliary forks, indexes, TOAST, growth history', '02_table_storage/01_table_size_breakdown.sql', 'Reconcile components before assigning growth to application rows.'),
    ('unknown_global_slowdown', 'cross_subsystem_triage', 'Wait classes, active work, locks, WAL, checkpoints, temp and cache', '38_observability_360/01_instance_health_360_dashboard.sql', 'Use the dominant evidence to choose one subsystem deep dive.')
) AS r(observed_symptom, suspected_subsystem, evidence_to_confirm, first_script, decision_rule)
ORDER BY observed_symptom;

-- SAMPLE_OUTPUT_BEGIN
-- observed_symptom | suspected_subsystem | evidence_to_confirm | first_script | decision_rule
-- blocking_or_lock_timeout | lock_manager | Waiters, blockers, lock mode... | 42_problem_identification_internals/02_lock_manager_full_diagnosis.sql | Resolve the blocking transaction...
-- SAMPLE_OUTPUT_END
