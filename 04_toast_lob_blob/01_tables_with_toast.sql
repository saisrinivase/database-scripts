/*
Purpose: List tables that own TOAST tables and their TOAST size.
Area: TOAST / LOB / BLOB
Usage: TOAST size helps explain hidden storage growth for wide rows.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    t.relname AS toast_table_name,
    pg_total_relation_size(t.oid) AS toast_total_bytes,
    pg_size_pretty(pg_total_relation_size(t.oid)) AS toast_total_pretty
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
JOIN pg_class t
    ON t.oid = c.reltoastrelid
WHERE c.relkind IN ('r', 'm')
  AND c.reltoastrelid <> 0
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY toast_total_bytes DESC;
