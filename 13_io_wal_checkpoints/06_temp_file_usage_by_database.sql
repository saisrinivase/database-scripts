/*
Purpose: Rank databases by temp file usage (spill pressure indicator).
Area: I/O, WAL, and Checkpoints
Usage: Tune query patterns and memory settings for top consumers.
*/
SELECT
    datname AS database_name,
    temp_files,
    temp_bytes,
    pg_size_pretty(temp_bytes) AS temp_pretty,
    xact_commit,
    xact_rollback,
    stats_reset
FROM pg_stat_database
WHERE datname NOT IN ('template0', 'template1')
ORDER BY temp_bytes DESC;
