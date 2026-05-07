/*
PostgreSQL DBA Script: DR RTO RPO Replication Evidence
Purpose: Produce DR evidence for RPO/RTO discussions from replication and replay state.
Area: Backup, Restore, PITR, and DR
Usage: Run on both primary and standby and compare outputs.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT (pg_is_in_recovery()) AS is_standby \gset

\if :is_standby
SELECT
    'standby' AS node_role,
    current_database() AS database_name,
    pg_last_wal_receive_lsn() AS last_received_lsn,
    pg_last_wal_replay_lsn() AS last_replayed_lsn,
    pg_wal_lsn_diff(pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn()) AS replay_lsn_gap_bytes,
    pg_last_xact_replay_timestamp() AS last_replay_timestamp,
    round(extract(epoch FROM (clock_timestamp() - pg_last_xact_replay_timestamp()))::numeric, 2) AS replay_delay_seconds,
    CASE
        WHEN pg_last_xact_replay_timestamp() IS NULL THEN 'NO_REPLAY_EVIDENCE'
        WHEN clock_timestamp() - pg_last_xact_replay_timestamp() > interval '60 seconds' THEN 'RPO_RISK_GT_60S'
        ELSE 'RPO_OK_LE_60S'
    END AS rpo_status
;
\else
SELECT
    'primary' AS node_role,
    current_database() AS database_name,
    application_name,
    client_addr,
    state,
    sync_state,
    sent_lsn,
    write_lsn,
    flush_lsn,
    replay_lsn,
    pg_wal_lsn_diff(sent_lsn, replay_lsn) AS send_replay_gap_bytes,
    coalesce(extract(epoch FROM replay_lag), 0)::numeric(18,2) AS replay_lag_seconds,
    coalesce(extract(epoch FROM write_lag), 0)::numeric(18,2) AS write_lag_seconds,
    coalesce(extract(epoch FROM flush_lag), 0)::numeric(18,2) AS flush_lag_seconds,
    CASE
        WHEN state <> 'streaming' THEN 'NOT_STREAMING'
        WHEN coalesce(extract(epoch FROM replay_lag), 0) > 60 THEN 'RPO_RISK_GT_60S'
        ELSE 'RPO_OK_LE_60S'
    END AS rpo_status
FROM pg_stat_replication
ORDER BY replay_lag_seconds DESC NULLS LAST, send_replay_gap_bytes DESC NULLS LAST;
\endif


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  node_role | database_name | application_name | client_addr | state | sync_state | sent_lsn | write_lsn | flush_lsn | replay_lsn | send_replay_gap_bytes | replay_lag_seconds | write_lag_seconds | flush_lag_seconds | rpo_status 
-- -----------+---------------+------------------+-------------+-------+------------+----------+-----------+-----------+------------+-----------------------+--------------------+-------------------+-------------------+------------
-- (0 rows)
-- 
-- SAMPLE_OUTPUT_END
