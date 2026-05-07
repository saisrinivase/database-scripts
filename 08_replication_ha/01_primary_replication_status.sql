/*
PostgreSQL DBA Script: Primary Replication Status
Purpose: Show standby status and lag metrics from a primary node.
Area: Replication and HA
Usage: Run on primary. On standby this view is typically empty.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  pid | user_name | application_name | client_addr | state | sync_state | sent_lsn | write_lsn | flush_lsn | replay_lsn | byte_lag | write_lag | flush_lag | replay_lag 
-- -----+-----------+------------------+-------------+-------+------------+----------+-----------+-----------+------------+----------+-----------+-----------+------------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No replication rows were found in this capture.
-- - This is expected on standalone instances or when replication features are not configured.
-- SAMPLE_OUTPUT_END

