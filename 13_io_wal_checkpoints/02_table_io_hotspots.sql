/*
Purpose: Identify tables with highest physical I/O pressure.
Area: I/O, WAL, and Checkpoints
Usage: Correlate with query plans and index strategy.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    heap_blks_read,
    heap_blks_hit,
    idx_blks_read,
    idx_blks_hit,
    toast_blks_read,
    toast_blks_hit,
    tidx_blks_read,
    tidx_blks_hit,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_statio_user_tables
ORDER BY heap_blks_read DESC, idx_blks_read DESC;
