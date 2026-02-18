/*
Purpose: Show per-table storage split (heap, index, TOAST, total).
Area: Table Storage
Usage: Run in target database; adjust WHERE clause for specific schemas.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    pg_relation_size(c.oid) AS heap_bytes,
    pg_indexes_size(c.oid) AS index_bytes,
    CASE WHEN c.reltoastrelid = 0 THEN 0 ELSE pg_total_relation_size(c.reltoastrelid) END AS toast_bytes,
    pg_total_relation_size(c.oid) AS total_bytes,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_pretty
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'm')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY total_bytes DESC;
