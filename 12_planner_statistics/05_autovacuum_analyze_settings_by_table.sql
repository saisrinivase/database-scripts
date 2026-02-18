/*
Purpose: Show table-level reloptions that override analyze/autovacuum behavior.
Area: Planner and Statistics
Usage: Review inconsistent per-table settings across critical schemas.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    c.reloptions
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'm', 'p')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
  AND c.reloptions IS NOT NULL
ORDER BY n.nspname, c.relname;
