/*
Purpose: Inspect per-table storage settings (fillfactor, autovacuum overrides, etc.).
Area: Table Storage
Usage: Useful when tuning table-level storage behavior.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    c.reloptions AS relation_options
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'm', 'p')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY n.nspname, c.relname;
