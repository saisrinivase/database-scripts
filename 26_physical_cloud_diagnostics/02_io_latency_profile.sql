/*
Purpose: Profile I/O latency per database to detect storage-level bottlenecks.
Area: Physical and Cloud Diagnostics
Usage: Compare with historical baselines and provider metrics.
*/
SELECT
    datname AS database_name,
    blks_read,
    blks_hit,
    blk_read_time,
    blk_write_time,
    CASE WHEN blks_read = 0 THEN NULL ELSE blk_read_time / blks_read END AS ms_per_block_read,
    CASE WHEN (xact_commit + xact_rollback) = 0 THEN NULL ELSE blk_write_time / (xact_commit + xact_rollback) END AS write_time_per_txn
FROM pg_stat_database
WHERE datname NOT IN ('template0', 'template1')
ORDER BY ms_per_block_read DESC NULLS LAST, blk_read_time DESC;
