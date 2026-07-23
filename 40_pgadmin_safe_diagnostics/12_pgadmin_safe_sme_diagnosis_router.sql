/*
PostgreSQL DBA Script: PgAdmin Safe SME Diagnosis Router
Purpose: pgAdmin-safe SME diagnosis router for PostgreSQL incident analysis.
Scope: Maps common symptoms to the right local script and first evidence to collect.
pgAdmin: Safe to run in Query Tool. Static plain SQL reference.
Sample output:
 symptom_keyword | start_with_script                                      | first_evidence
-----------------+--------------------------------------------------------+-----------------------------
 locks           | 09_pgadmin_safe_observer_health_dashboard.sql          | lock waiters and blockers
*/

SELECT *
FROM (
    VALUES
        ('locks/blocking/deadlock', '09_pgadmin_safe_observer_health_dashboard.sql', 'pg_stat_activity wait_event_type=Lock, pg_blocking_pids(), deadlocks', 'Resolve blockers before CPU/query tuning.'),
        ('slow query/top sql/cpu', '05_pgadmin_safe_pg_stat_statements_quality.sql', 'total_exec_time, mean_exec_time, calls, rows_per_call', 'Use EXPLAIN ANALYZE on the highest business-impact query.'),
        ('temp spill/disk sort', '05_pgadmin_safe_pg_stat_statements_quality.sql', 'temp_blks_read, temp_blks_written, temp_bytes', 'Check work_mem scope, plan shape, row estimates, joins, and indexes.'),
        ('wal growth/archive', '08_pgadmin_safe_wal_checkpoint_archiver.sql', 'wal_bytes, archive failures, checkpoint pressure', 'Separate normal write workload from archive failure or checkpoint mis-sizing.'),
        ('checkpoint/io latency', '03_pgadmin_safe_checkpoint_bgwriter.sql', 'requested checkpoint pct, write time, sync time, buffers checkpoint', 'Tune max_wal_size/checkpoint_timeout/checkpoint_completion_target after storage validation.'),
        ('io/read/write/fsync', '04_pgadmin_safe_pg_stat_io_overview.sql', 'read_time, write_time, fsync_time, evictions', 'Use pg_stat_io on PG16+; correlate with cloud/storage metrics.'),
        ('replication lag/ha', '07_pgadmin_safe_replication_ha_dashboard.sql', 'replay lag, slot retained WAL, receiver status', 'Check standby apply, network, long standby queries, and slot consumers.'),
        ('xid age/vacuum/bloat', '02_pgadmin_safe_vacuum_progress.sql', 'vacuum phase, xact age, backend_xmin holders', 'Clear blockers and prioritize anti-wraparound risk before routine tuning.'),
        ('cloudwatch/rds metrics', '06_pgadmin_safe_cloudwatch_metric_equivalents.sql', 'connections, temp, cache hit, locks, lag, archiver, WAL', 'SQL can cover database-internal metrics; OS/cloud-only metrics need provider tools.'),
        ('incident queue/where to start', '10_pgadmin_safe_root_cause_action_queue.sql', 'prioritized P1/P2/P3 findings', 'Start with P1 safety risks, then bottlenecks, then tuning hygiene.'),
        ('backup/restore/pitr/dr', '11_pgadmin_safe_backup_restore_evidence.sql', 'archive mode, WAL level, archive failures, slots, custom backup history', 'Database views prove prerequisites, but restore testing evidence must come from backup tooling.'),
        ('pgadmin compatibility', '01_pgadmin_compatibility_audit.sql', 'replacement mapping for psql-meta scripts', 'Use this pack in pgAdmin Query Tool; psql workflow scripts remain command-line only.')
) AS router(symptom_keyword, start_with_script, first_evidence, first_action)
ORDER BY symptom_keyword;

-- SAMPLE_OUTPUT_BEGIN
-- symptom_keyword      | start_with_script                                      | first_evidence                  | first_action
-- ---------------------+--------------------------------------------------------+---------------------------------+------------------------------
-- locks/blocking/...   | 09_pgadmin_safe_observer_health_dashboard.sql          | pg_stat_activity wait_event...  | Resolve blockers before...
-- SAMPLE_OUTPUT_END
