/*
Purpose: Quickly list the largest tables in the current database.
Area: Table Storage
Usage: Change LIMIT value based on reporting need.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    pg_total_relation_size(c.oid) AS total_bytes,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_pretty,
    s.n_live_tup AS estimated_live_rows,
    s.n_dead_tup AS estimated_dead_rows
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
LEFT JOIN pg_stat_user_tables s
    ON s.relid = c.oid
WHERE c.relkind IN ('r', 'm')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY total_bytes DESC
LIMIT 50;
