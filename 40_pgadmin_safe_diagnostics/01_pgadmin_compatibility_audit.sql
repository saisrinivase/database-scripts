/*
PostgreSQL DBA Script: PgAdmin Compatibility Audit
Purpose: List psql-only diagnostic patterns and the pgAdmin-safe replacement scripts in this repository.
Area: PgAdmin Safe Diagnostics
Usage: Run in pgAdmin Query Tool to find the plain-SQL script to use for each diagnostic area.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only static compatibility map.
*/
SELECT *
FROM (VALUES
    ('vacuum_progress', '07_vacuum_bloat/05_vacuum_progress.sql', '40_pgadmin_safe_diagnostics/02_pgadmin_safe_vacuum_progress.sql', 'Version-guarded vacuum progress without psql \\if.'),
    ('checkpoint_bgwriter', '10_maintenance_monitoring/01_bgwriter_checkpoint_stats.sql', '40_pgadmin_safe_diagnostics/03_pgadmin_safe_checkpoint_bgwriter.sql', 'Checkpoint/bgwriter view split handled with pg_temp function.'),
    ('checkpoint_pressure', '13_io_wal_checkpoints/05_checkpoint_pressure_indicators.sql', '40_pgadmin_safe_diagnostics/03_pgadmin_safe_checkpoint_bgwriter.sql', 'Checkpoint pressure usable in pgAdmin.'),
    ('pg_stat_io', '13_io_wal_checkpoints/07_pg_stat_io_overview_pg16_plus.sql', '40_pgadmin_safe_diagnostics/04_pgadmin_safe_pg_stat_io_overview.sql', 'pg_stat_io availability handled without psql \\if.'),
    ('pg_stat_statements_quality', '38_observability_360/10_query_capture_quality_pgss.sql', '40_pgadmin_safe_diagnostics/05_pgadmin_safe_pg_stat_statements_quality.sql', 'Optional pg_stat_statements handled safely.'),
    ('cloudwatch_mapping', '38_observability_360/02_cloudwatch_metric_equivalents.sql', '40_pgadmin_safe_diagnostics/06_pgadmin_safe_cloudwatch_metric_equivalents.sql', 'CloudWatch-style SQL-visible map for pgAdmin.'),
    ('replication_ha', '36_cloud_provider_signals/03_replica_lag_failover_signals.sql', '40_pgadmin_safe_diagnostics/07_pgadmin_safe_replication_ha_dashboard.sql', 'Primary/standby dashboard without psql branching.'),
    ('wal_checkpoint_archiver', '38_observability_360/07_wal_checkpoint_archiver_dashboard.sql', '40_pgadmin_safe_diagnostics/08_pgadmin_safe_wal_checkpoint_archiver.sql', 'WAL/checkpoint/archive status in plain SQL.'),
    ('observer_health', '39_observer_agent_monitoring/03_health_score_dashboard.sql', '40_pgadmin_safe_diagnostics/09_pgadmin_safe_observer_health_dashboard.sql', 'Observer repository optional handling for pgAdmin.'),
    ('root_cause_queue', '39_observer_agent_monitoring/06_top_root_cause_action_queue.sql', '40_pgadmin_safe_diagnostics/10_pgadmin_safe_root_cause_action_queue.sql', 'Root-cause queue with optional pg_stat_statements handling.'),
    ('backup_restore_evidence', '30_backup_restore_pitr_dr/05_backup_restore_evidence_contract.sql', '40_pgadmin_safe_diagnostics/11_pgadmin_safe_backup_restore_evidence.sql', 'Optional evidence table handled safely.'),
    ('diagnosis_router', '38_observability_360/12_sme_triage_command_router.sql', '40_pgadmin_safe_diagnostics/12_pgadmin_safe_sme_diagnosis_router.sql', 'SME route map for pgAdmin users.')
) AS m(component, psql_or_original_script, pgadmin_safe_script, compatibility_note)
ORDER BY component;

-- SAMPLE_OUTPUT_BEGIN
-- component          | psql_or_original_script                         | pgadmin_safe_script                                      | compatibility_note
-- -------------------+-------------------------------------------------+----------------------------------------------------------+------------------------------
-- vacuum_progress    | 07_vacuum_bloat/05_vacuum_progress.sql          | 40_pgadmin_safe_diagnostics/02_pgadmin_safe_vacuum...   | Version-guarded...
-- SAMPLE_OUTPUT_END
