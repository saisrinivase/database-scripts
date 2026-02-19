/*
Purpose: Provide portable failover and replica-lag signals for managed or self-managed platforms.
Area: Cloud Provider Signals
Usage: Run on primary and standby; compare role-specific output.
*/
SELECT (pg_is_in_recovery()) AS is_standby \gset

\if :is_standby
SELECT
    'standby' AS node_role,
    pg_postmaster_start_time() AS postmaster_start_time,
    pg_last_wal_receive_lsn() AS last_received_lsn,
    pg_last_wal_replay_lsn() AS last_replayed_lsn,
    pg_wal_lsn_diff(pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn()) AS replay_gap_bytes,
    pg_last_xact_replay_timestamp() AS last_replay_timestamp,
    round(extract(epoch FROM (clock_timestamp() - pg_last_xact_replay_timestamp()))::numeric, 2) AS replay_delay_seconds,
    CASE
        WHEN pg_last_xact_replay_timestamp() IS NULL THEN 'NO_REPLAY_SIGNAL'
        WHEN clock_timestamp() - pg_last_xact_replay_timestamp() > interval '60 seconds' THEN 'LAG_RISK'
        ELSE 'HEALTHY_REPLAY'
    END AS lag_status
;
\else
SELECT
    'primary' AS node_role,
    pg_postmaster_start_time() AS postmaster_start_time,
    application_name,
    client_addr,
    state,
    sync_state,
    sent_lsn,
    replay_lsn,
    pg_wal_lsn_diff(sent_lsn, replay_lsn) AS send_replay_gap_bytes,
    coalesce(extract(epoch FROM replay_lag), 0)::numeric(18,2) AS replay_lag_seconds,
    CASE
        WHEN state <> 'streaming' THEN 'REPLICA_NOT_STREAMING'
        WHEN coalesce(extract(epoch FROM replay_lag), 0) > 60 THEN 'LAG_RISK'
        ELSE 'HEALTHY_STREAMING'
    END AS lag_status
FROM pg_stat_replication
ORDER BY replay_lag_seconds DESC NULLS LAST, send_replay_gap_bytes DESC NULLS LAST;
\endif


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  node_role | postmaster_start_time | application_name | client_addr | state | sync_state | sent_lsn | replay_lsn | send_replay_gap_bytes | replay_lag_seconds | lag_status 
-- -----------+-----------------------+------------------+-------------+-------+------------+----------+------------+-----------------------+--------------------+------------
-- (0 rows)
-- 
-- SAMPLE_OUTPUT_END
