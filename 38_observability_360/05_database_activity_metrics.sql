/*
PostgreSQL DBA Script: Database Activity Metrics
Purpose: Show per-database transaction, cache, row, temp, conflict, deadlock, and timing counters in one place.
Area: Observability 360
Usage: Run for daily baselines or when deciding which database is the noisy tenant.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Counters are cumulative since stats reset.
*/
SELECT
    datname AS database_name,
    numbackends AS current_backends,
    xact_commit,
    xact_rollback,
    round(100.0 * xact_commit / NULLIF(xact_commit + xact_rollback, 0), 2) AS commit_pct,
    blks_read,
    blks_hit,
    round(100.0 * blks_hit / NULLIF(blks_hit + blks_read, 0), 2) AS cache_hit_pct,
    tup_returned,
    tup_fetched,
    tup_inserted,
    tup_updated,
    tup_deleted,
    conflicts,
    deadlocks,
    temp_files,
    temp_bytes,
    pg_size_pretty(temp_bytes) AS temp_bytes_pretty,
    blk_read_time,
    blk_write_time,
    session_time,
    active_time,
    idle_in_transaction_time,
    stats_reset
FROM pg_stat_database
WHERE datname IS NOT NULL
ORDER BY temp_bytes DESC, blks_read DESC, xact_commit DESC;

-- SAMPLE_OUTPUT_BEGIN
-- database_name | current_backends | xact_commit | cache_hit_pct | deadlocks | temp_bytes_pretty | blk_read_time
-- --------------+------------------+-------------+---------------+-----------+-------------------+--------------
-- appdb         |               38 |    92837422 |         99.42 |         0 | 18 GB             |     82391.42
-- postgres      |                2 |       12345 |         98.81 |         0 | 64 MB             |       120.77
-- SAMPLE_OUTPUT_END
