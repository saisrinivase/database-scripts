/*
Purpose: Report recovery/replay state when connected to a standby node.
Area: Replication and HA
Usage: Run on standby for replay delay checks.
*/
SELECT
    pg_is_in_recovery() AS is_standby,
    pg_last_wal_receive_lsn() AS last_received_lsn,
    pg_last_wal_replay_lsn() AS last_replayed_lsn,
    pg_last_xact_replay_timestamp() AS last_replay_timestamp,
    CASE
        WHEN pg_last_xact_replay_timestamp() IS NULL THEN NULL
        ELSE now() - pg_last_xact_replay_timestamp()
    END AS replay_delay;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 is_standby | last_received_lsn | last_replayed_lsn | last_replay_timestamp | replay_delay 
------------+-------------------+-------------------+-----------------------+--------------
 f          |                   |                   |                       | 
(1 row)


SAMPLE_OUTPUT_END */
