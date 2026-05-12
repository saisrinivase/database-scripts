/*
PostgreSQL DBA Script: Replica Lag Failover Signals
Purpose: Provide portable failover and replica-lag signals for managed or self-managed platforms.
Area: Cloud Provider Signals
Usage: Run on primary and standby; compare role-specific output. Safe for pgAdmin and psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic.
*/
SELECT
    'standby' AS node_role,
    pg_postmaster_start_time() AS postmaster_start_time,
    NULL::text AS application_name,
    NULL::inet AS client_addr,
    NULL::text AS state,
    NULL::text AS sync_state,
    pg_last_wal_receive_lsn() AS sent_lsn,
    pg_last_wal_replay_lsn() AS replay_lsn,
    pg_wal_lsn_diff(pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn()) AS send_replay_gap_bytes,
    round(extract(epoch FROM (clock_timestamp() - pg_last_xact_replay_timestamp()))::numeric, 2) AS replay_lag_seconds,
    CASE
        WHEN pg_last_xact_replay_timestamp() IS NULL THEN 'NO_REPLAY_SIGNAL'
        WHEN clock_timestamp() - pg_last_xact_replay_timestamp() > interval '60 seconds' THEN 'LAG_RISK'
        ELSE 'HEALTHY_REPLAY'
    END AS lag_status
WHERE pg_is_in_recovery()

UNION ALL

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
WHERE NOT pg_is_in_recovery()
ORDER BY replay_lag_seconds DESC NULLS LAST, send_replay_gap_bytes DESC NULLS LAST;

-- SAMPLE_OUTPUT_BEGIN
-- node_role | postmaster_start_time | application_name | client_addr | state | sync_state | sent_lsn | replay_lsn | send_replay_gap_bytes | replay_lag_seconds | lag_status
-- ----------+-----------------------+------------------+-------------+-------+------------+----------+------------+-----------------------+--------------------+-----------
-- (0 rows)
-- SAMPLE_OUTPUT_END
