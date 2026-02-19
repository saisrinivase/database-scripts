/*
Purpose: Inventory full-text search building blocks (tsvector/tsquery related columns and indexes).
Area: Complex Filtering and Search
Usage: Use when evaluating search architecture.
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
  AND pg_catalog.format_type(a.atttypid, a.atttypmod) IN ('tsvector', 'tsquery')
ORDER BY schema_name, table_name, column_name;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 schema_name | table_name | column_name | data_type 
-------------+------------+-------------+-----------
(0 rows)


SAMPLE_OUTPUT_END */
