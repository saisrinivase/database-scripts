/*
Purpose: Identify non-unique/non-primary indexes that have never been scanned.
Area: Index Analysis
Usage: Review manually before dropping; low-traffic windows may hide infrequent use.
*/
SELECT
    s.schemaname AS schema_name,
    s.relname AS table_name,
    s.indexrelname AS index_name,
    pg_relation_size(s.indexrelid) AS index_bytes,
    pg_size_pretty(pg_relation_size(s.indexrelid)) AS index_pretty,
    s.idx_scan
FROM pg_stat_user_indexes s
JOIN pg_index i
    ON i.indexrelid = s.indexrelid
WHERE s.idx_scan = 0
  AND NOT i.indisunique
  AND NOT i.indisprimary
ORDER BY index_bytes DESC;
