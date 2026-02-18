/*
Purpose: Correlate index size with usage counters to find expensive or cold indexes.
Area: Index Analysis
Usage: Reset stats only when intentional; counters are cumulative since reset/restart.
*/
SELECT
    s.schemaname AS schema_name,
    s.relname AS table_name,
    s.indexrelname AS index_name,
    pg_relation_size(s.indexrelid) AS index_bytes,
    pg_size_pretty(pg_relation_size(s.indexrelid)) AS index_pretty,
    s.idx_scan,
    s.idx_tup_read,
    s.idx_tup_fetch
FROM pg_stat_user_indexes s
ORDER BY index_bytes DESC;
