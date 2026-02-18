/*
Purpose: Find tables where TOAST occupies a large share of total table size.
Area: TOAST / LOB / BLOB
Usage: Useful for column-level compression/archive strategy reviews.
*/
WITH toast_stats AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS table_name,
        pg_total_relation_size(c.oid) AS table_total_bytes,
        CASE WHEN c.reltoastrelid = 0 THEN 0 ELSE pg_total_relation_size(c.reltoastrelid) END AS toast_bytes
    FROM pg_class c
    JOIN pg_namespace n
        ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r', 'm')
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
)
SELECT
    schema_name,
    table_name,
    table_total_bytes,
    pg_size_pretty(table_total_bytes) AS table_total_pretty,
    toast_bytes,
    pg_size_pretty(toast_bytes) AS toast_pretty,
    round(100.0 * toast_bytes / NULLIF(table_total_bytes, 0), 2) AS toast_pct
FROM toast_stats
WHERE table_total_bytes > 0
ORDER BY toast_pct DESC, toast_bytes DESC;
