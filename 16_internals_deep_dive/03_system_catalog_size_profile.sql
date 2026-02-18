/*
Purpose: Profile largest system catalogs to understand metadata footprint.
Area: Internals Deep Dive
Usage: Run in each critical database.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS catalog_name,
    c.relkind,
    pg_total_relation_size(c.oid) AS total_bytes,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_pretty
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE n.nspname IN ('pg_catalog', 'information_schema')
ORDER BY total_bytes DESC;
