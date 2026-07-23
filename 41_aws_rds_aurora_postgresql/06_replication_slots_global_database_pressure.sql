/*
PostgreSQL DBA Script: AWS Replication Slots Global Database Pressure
Purpose: Deep-dive RDS/Aurora replica lag, slot lag/disk usage, RDS-to-Aurora lag, and Aurora Global Database lag/RPO/data-transfer alarms.
Area: AWS RDS and Aurora PostgreSQL
Usage: Run on writer and affected reader when possible; compare SQL timestamps/LSNs with the same CloudWatch window.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only. Aurora Global Database service-layer metrics remain AWS-only.
*/
SELECT
    'server_role' AS report_section,
    current_database() AS database_name,
    pg_is_in_recovery() AS is_standby,
    pg_last_wal_receive_lsn() AS last_receive_lsn,
    pg_last_wal_replay_lsn() AS last_replay_lsn,
    pg_last_xact_replay_timestamp() AS last_replay_timestamp,
    CASE
        WHEN NOT pg_is_in_recovery() THEN NULL
        ELSE clock_timestamp() - pg_last_xact_replay_timestamp()
    END AS standby_replay_delay,
    CASE
        WHEN pg_is_in_recovery() THEN 'Run receiver/replay checks and inspect recovery conflicts.'
        ELSE 'Run sender and replication-slot checks.'
    END AS next_step;

SELECT
    application_name,
    client_addr,
    state,
    sync_state,
    sent_lsn,
    write_lsn,
    flush_lsn,
    replay_lsn,
    write_lag,
    flush_lag,
    replay_lag,
    pg_wal_lsn_diff(sent_lsn, replay_lsn) AS sent_to_replay_lag_bytes,
    backend_start,
    reply_time,
    CASE
        WHEN state <> 'streaming' THEN 'Replication sender is not streaming.'
        WHEN replay_lag >= interval '60 seconds' THEN 'Replay lag is at least 60 seconds.'
        WHEN pg_wal_lsn_diff(sent_lsn, replay_lsn) >= 1024::numeric * 1024 * 1024 THEN 'Replay is at least 1 GB behind sent WAL.'
        ELSE 'No sender-side threshold breach in this snapshot.'
    END AS diagnosis
FROM pg_stat_replication
ORDER BY sent_to_replay_lag_bytes DESC NULLS LAST;

SELECT
    slot_name,
    slot_type,
    database,
    active,
    active_pid,
    restart_lsn,
    confirmed_flush_lsn,
    coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn), 0) AS retained_wal_bytes,
    pg_size_pretty(coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn), 0)) AS retained_wal_pretty,
    wal_status,
    safe_wal_size,
    CASE
        WHEN NOT active
         AND coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn), 0) >= 10::numeric * 1024 * 1024 * 1024
            THEN 'CRITICAL: inactive slot retains at least 10 GB.'
        WHEN NOT active THEN 'REVIEW: inactive slot can retain WAL.'
        WHEN coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn), 0) >= 10::numeric * 1024 * 1024 * 1024
            THEN 'HIGH: active consumer is at least 10 GB behind.'
        ELSE 'No slot threshold breach in this snapshot.'
    END AS diagnosis,
    'Confirm consumer ownership and recovery requirements before changing or dropping any slot.' AS safety_note
FROM pg_replication_slots
ORDER BY retained_wal_bytes DESC;

SELECT
    status,
    sender_host,
    sender_port,
    slot_name,
    written_lsn,
    flushed_lsn,
    received_tli,
    last_msg_send_time,
    last_msg_receipt_time,
    latest_end_lsn,
    latest_end_time,
    conninfo
FROM pg_stat_wal_receiver;

SELECT
    c.datname,
    c.confl_tablespace,
    c.confl_lock,
    c.confl_snapshot,
    c.confl_bufferpin,
    c.confl_deadlock,
    coalesce((to_jsonb(c) ->> 'confl_active_logicalslot')::bigint, 0) AS confl_active_logicalslot
FROM pg_stat_database_conflicts c
WHERE c.datname IS NOT NULL
ORDER BY
    c.confl_tablespace
    + c.confl_lock
    + c.confl_snapshot
    + c.confl_bufferpin
    + c.confl_deadlock
    + coalesce((to_jsonb(c) ->> 'confl_active_logicalslot')::bigint, 0) DESC;

SELECT *
FROM (VALUES
    ('AuroraGlobalDBDataTransferBytes', 'AWS_ONLY', 'Cross-Region network bytes are not exposed by PostgreSQL SQL. Correlate with WAL generation.'),
    ('AuroraGlobalDBProgressLag', 'AWS_ONLY', 'Aurora storage progress lag is service-layer state. Correlate with replay and storage pressure.'),
    ('AuroraGlobalDBRPOLag', 'AWS_ONLY', 'Global Database RPO is authoritative in AWS. Correlate with transaction/WAL rate.'),
    ('AuroraGlobalDBReplicatedWriteIO', 'AWS_ONLY', 'Cross-Region storage writes are authoritative in AWS. Correlate with WAL and write workload.'),
    ('AuroraGlobalDBReplicationLag', 'AWS_ONLY', 'Cross-Region replication-server lag is authoritative in AWS. Correlate with local receiver/replay state.'),
    ('RDSToAuroraPostgreSQLReplicaLag', 'AWS_ONLY_WITH_SQL_CORRELATION', 'Use AWS for migration-channel lag and this script for receiver/replay evidence.')
) AS aws_global_metric_boundary(metric_name, visibility, interpretation);

-- SAMPLE_OUTPUT_BEGIN
-- application_name | state | replay_lag | sent_to_replay_lag_bytes | diagnosis
-- slot_name | active | retained_wal_pretty | wal_status | diagnosis
-- SAMPLE_OUTPUT_END
