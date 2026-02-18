/*
Purpose: Profile read/write, temp, and transaction behavior by database.
Area: I/O, WAL, and Checkpoints
Usage: Compare across databases to identify noisy tenants.
*/
SELECT
    datname AS database_name,
    numbackends,
    xact_commit,
    xact_rollback,
    blks_read,
    blks_hit,
    tup_returned,
    tup_fetched,
    tup_inserted,
    tup_updated,
    tup_deleted,
    temp_files,
    temp_bytes,
    deadlocks,
    blk_read_time,
    blk_write_time,
    stats_reset
FROM pg_stat_database
WHERE datname NOT IN ('template0', 'template1')
ORDER BY blks_read DESC, temp_bytes DESC;
