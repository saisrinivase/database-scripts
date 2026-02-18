/*
Purpose: Summarize mixed-workload pressure indicators by database.
Area: Optimization Goals (OLTP vs OLAP)
Usage: Useful for deciding workload isolation strategy.
*/
SELECT
    d.datname AS database_name,
    d.xact_commit,
    d.xact_rollback,
    d.blks_read,
    d.blks_hit,
    d.temp_files,
    d.temp_bytes,
    d.deadlocks,
    d.blk_read_time,
    d.blk_write_time,
    d.numbackends,
    CASE
        WHEN d.xact_commit > 0 AND d.temp_bytes > 0 AND d.blks_read > d.blks_hit / 4 THEN 'Mixed workload pressure'
        ELSE 'Normal/Mild'
    END AS recommendation
FROM pg_stat_database d
WHERE d.datname NOT IN ('template0', 'template1')
ORDER BY d.temp_bytes DESC, d.blks_read DESC;
