/*
PostgreSQL DBA Script: Replication And Slot Dashboard
Purpose: Show primary-side standby lag, standby receiver state, replication slots, and WAL retention risk.
Area: Observability 360
Usage: Run on primary and standby during HA, lag, failover, or WAL disk-growth investigations.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Some result sets are empty depending on whether the node is primary or standby.
*/
SELECT
    pg_is_in_recovery() AS is_standby,
    pg_last_wal_receive_lsn() AS standby_receive_lsn,
    pg_last_wal_replay_lsn() AS standby_replay_lsn,
    CASE
        WHEN pg_is_in_recovery() THEN now() - pg_last_xact_replay_timestamp()
        ELSE NULL
    END AS standby_replay_delay;

SELECT
    pid,
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
    pg_wal_lsn_diff(sent_lsn, replay_lsn) AS sent_replay_lag_bytes
FROM pg_stat_replication
ORDER BY sent_replay_lag_bytes DESC NULLS LAST;

SELECT
    slot_name,
    slot_type,
    database,
    active,
    restart_lsn,
    confirmed_flush_lsn,
    wal_status,
    safe_wal_size,
    pg_size_pretty(coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn), 0)) AS retained_wal_pretty,
    pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) AS retained_wal_bytes
FROM pg_replication_slots
ORDER BY retained_wal_bytes DESC NULLS LAST;

SELECT
    status,
    receive_start_lsn,
    written_lsn,
    flushed_lsn,
    latest_end_lsn,
    latest_end_time,
    now() - latest_end_time AS latest_end_age,
    slot_name,
    sender_host,
    conninfo
FROM pg_stat_wal_receiver;

-- SAMPLE_OUTPUT_BEGIN
-- is_standby | standby_receive_lsn | standby_replay_lsn | standby_replay_delay
-- -----------+---------------------+--------------------+---------------------
-- false      |                     |                    |
--
-- slot_name      | slot_type | active | retained_wal_pretty | retained_wal_bytes
-- ---------------+-----------+--------+---------------------+-------------------
-- logical_app_01 | logical   | t      | 512 MB              |         536870912
-- SAMPLE_OUTPUT_END
