/*
Purpose: Find tables with potentially excessive index count relative to write activity.
Area: Design Matters
Usage: Over-indexing can slow INSERT/UPDATE/DELETE workloads.
*/
WITH idx_count AS (
    SELECT
        i.indrelid AS relid,
        count(*) AS index_count
    FROM pg_index i
    GROUP BY i.indrelid
)
SELECT
    s.schemaname AS schema_name,
    s.relname AS table_name,
    coalesce(i.index_count, 0) AS index_count,
    (s.n_tup_ins + s.n_tup_upd + s.n_tup_del) AS total_writes,
    pg_size_pretty(pg_total_relation_size(s.relid)) AS total_size
FROM pg_stat_user_tables s
LEFT JOIN idx_count i
    ON i.relid = s.relid
ORDER BY index_count DESC, total_writes DESC;
