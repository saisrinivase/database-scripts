/*
Purpose: Profile table width and column counts to detect design patterns that can degrade performance.
Area: Design Matters
Usage: Use with normalization and access pattern review.
*/
WITH col AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS table_name,
        count(a.attnum) FILTER (WHERE a.attnum > 0 AND NOT a.attisdropped) AS column_count
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    JOIN pg_attribute a ON a.attrelid = c.oid
    WHERE c.relkind = 'r'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
    GROUP BY n.nspname, c.relname, c.oid
)
SELECT
    c.schema_name,
    c.table_name,
    c.column_count,
    s.n_live_tup AS estimated_live_rows,
    pg_size_pretty(pg_total_relation_size(s.relid)) AS total_size
FROM col c
JOIN pg_stat_user_tables s
    ON s.schemaname = c.schema_name
   AND s.relname = c.table_name
ORDER BY c.column_count DESC, pg_total_relation_size(s.relid) DESC;
