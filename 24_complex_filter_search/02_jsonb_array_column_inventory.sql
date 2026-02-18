/*
Purpose: Inventory JSON/JSONB/array columns that often need specialized indexing.
Area: Complex Filtering and Search
Usage: Review with query patterns before index design.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    a.attname AS column_name,
    pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type
FROM pg_attribute a
JOIN pg_class c
    ON c.oid = a.attrelid
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE c.relkind = 'r'
  AND a.attnum > 0
  AND NOT a.attisdropped
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
  AND (
      pg_catalog.format_type(a.atttypid, a.atttypmod) IN ('json', 'jsonb')
      OR pg_catalog.format_type(a.atttypid, a.atttypmod) LIKE '%[]'
  )
ORDER BY schema_name, table_name, column_name;
