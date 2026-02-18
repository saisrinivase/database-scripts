/*
Purpose: Highlight large indexes with low scan counts as maintenance/drop review candidates.
Area: Index Analysis
Usage: This is heuristic guidance, not an automatic drop list.
*/
SELECT
    s.schemaname AS schema_name,
    s.relname AS table_name,
    s.indexrelname AS index_name,
    pg_relation_size(s.indexrelid) AS index_bytes,
    pg_size_pretty(pg_relation_size(s.indexrelid)) AS index_pretty,
    s.idx_scan,
    CASE
        WHEN s.idx_scan = 0 AND pg_relation_size(s.indexrelid) >= 1024::bigint * 1024 * 1024
            THEN 'High priority review'
        WHEN s.idx_scan < 100 AND pg_relation_size(s.indexrelid) >= 512::bigint * 1024 * 1024
            THEN 'Medium priority review'
        ELSE 'Observe'
    END AS recommendation
FROM pg_stat_user_indexes s
ORDER BY index_bytes DESC;
