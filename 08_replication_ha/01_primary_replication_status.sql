/*
Purpose: Show standby status and lag metrics from a primary node.
Area: Replication and HA
Usage: Run on primary. On standby this view is typically empty.
*/
SELECT
    pid,
    usename AS user_name,
    application_name,
    client_addr,
    state,
    sync_state,
    sent_lsn,
    write_lsn,
    flush_lsn,
    replay_lsn,
    pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) AS byte_lag,
    write_lag,
    flush_lag,
    replay_lag
FROM pg_stat_replication
ORDER BY byte_lag DESC NULLS LAST;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 pid | user_name | application_name | client_addr | state | sync_state | sent_lsn | write_lsn | flush_lsn | replay_lsn | byte_lag | write_lag | flush_lag | replay_lag 
-----+-----------+------------------+-------------+-------+------------+----------+-----------+-----------+------------+----------+-----------+-----------+------------
(0 rows)


SAMPLE_OUTPUT_END */
