/*
Purpose: Map logical relation names to relfilenode and tablespace internals.
Area: Internals Deep Dive
Usage: Useful for low-level storage troubleshooting.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS relation_name,
    c.relkind,
    c.oid AS relation_oid,
    pg_relation_filenode(c.oid) AS relfilenode,
    c.reltablespace,
    pg_relation_filepath(c.oid) AS relation_filepath
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY n.nspname, c.relname;
