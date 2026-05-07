/*
PostgreSQL DBA Script: SME Triage Command Router
Purpose: Map common DBA symptoms to the best scripts in this repository so users can move from signal to diagnosis quickly.
Area: Observability 360
Usage: Run when you know the symptom but not which script to use next.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only repository guide returned as SQL rows.
*/
SELECT *
FROM (VALUES
    ('first_look', 'unknown slowdown or incident', '38_observability_360/01_instance_health_360_dashboard.sql', 'Start here for connection, lock, temp, WAL, checkpoint, and replication signal.'),
    ('cloudwatch_like', 'need CloudWatch-style metrics in psql', '38_observability_360/02_cloudwatch_metric_equivalents.sql', 'Shows SQL-visible equivalents and host/cloud-only gaps.'),
    ('observability_readiness', 'are required stats enabled', '38_observability_360/03_stat_view_coverage_check.sql', 'Checks pg_stat views, pg_stat_statements, and timing settings.'),
    ('waits', 'sessions waiting or latency spike', '38_observability_360/04_wait_event_hotspots.sql', 'Summarizes current wait events by type/event/application.'),
    ('database_noisy_tenant', 'which database is causing load', '38_observability_360/05_database_activity_metrics.sql', 'Per-database transactions, cache, temp, deadlocks, and timing.'),
    ('table_index_pressure', 'which table or index is hot', '38_observability_360/06_table_index_activity_heatmap.sql', 'Combines table writes, scans, index activity, size, and dead tuples.'),
    ('wal_checkpoint', 'write latency, WAL growth, archive issue', '38_observability_360/07_wal_checkpoint_archiver_dashboard.sql', 'WAL bytes, WAL sync, checkpoint ratio, archiver failures.'),
    ('vacuum_analyze', 'bloat, stale stats, autovacuum backlog', '38_observability_360/08_autovacuum_vacuum_analyze_progress.sql', 'Current progress plus backlog by table.'),
    ('replication', 'replica lag, slot lag, WAL retained', '38_observability_360/09_replication_and_slot_dashboard.sql', 'Primary, standby, slot, and receiver signals.'),
    ('query_history', 'can we trust top SQL reports', '38_observability_360/10_query_capture_quality_pgss.sql', 'Validates pg_stat_statements and shows capture quality.'),
    ('capacity', 'growth, storage, xid, temp review', '38_observability_360/11_growth_and_capacity_snapshot_now.sql', 'One-shot capacity snapshot before scheduled trend capture.'),
    ('blocking', 'blocked sessions or lock chains', '06_activity_locks/02_blocking_and_blocked_sessions.sql', 'Detailed blocker and blocked session query.'),
    ('top_sql', 'highest total execution time SQL', '11_performance_tuning/01_top_queries_by_total_exec_time.sql', 'Requires pg_stat_statements.'),
    ('plan_review', 'need explain commands for top SQL', '17_execution_plans/03_generate_explain_for_top_queries.sql', 'Generates EXPLAIN commands for manual execution.'),
    ('missing_indexes', 'large sequential scan pressure', '27_high_speed_tuning/03_missing_index_candidates_from_scan_pressure.sql', 'Finds high scan pressure tables; verify predicates before indexing.'),
    ('fk_indexes', 'parent deletes or FK locking slow', '27_high_speed_tuning/04_missing_fk_index_candidates.sql', 'Finds missing supporting indexes for foreign keys.'),
    ('parameter_tuning', 'settings may be undersized or risky', '27_high_speed_tuning/05_parameter_tuning_advisor.sql', 'Actionable parameter advisor with severity.'),
    ('backup_pitr', 'is PITR/archive safe', '30_backup_restore_pitr_dr/01_backup_pitr_configuration_health.sql', 'Backup, WAL archive, restore, and DR readiness.'),
    ('upgrade', 'pre-upgrade or patch readiness', '32_upgrade_patch_readiness/01_pre_upgrade_readiness_gate.sql', 'Upgrade posture and blockers.'),
    ('integrity', 'corruption or catalog consistency concern', '34_consistency_integrity_checks/04_amcheck_readiness_and_candidate_commands.sql', 'amcheck readiness and candidate validation commands.')
) AS router(priority_area, symptom, run_script, why_this_script)
ORDER BY priority_area, symptom;

-- SAMPLE_OUTPUT_BEGIN
-- priority_area | symptom                              | run_script                                                     | why_this_script
-- --------------+--------------------------------------+----------------------------------------------------------------+-----------------------------------------
-- first_look    | unknown slowdown or incident          | 38_observability_360/01_instance_health_360_dashboard.sql      | Start here for connection, lock...
-- replication   | replica lag, slot lag, WAL retained   | 38_observability_360/09_replication_and_slot_dashboard.sql     | Primary, standby, slot, and receiver...
-- top_sql       | highest total execution time SQL      | 11_performance_tuning/01_top_queries_by_total_exec_time.sql    | Requires pg_stat_statements.
-- SAMPLE_OUTPUT_END
