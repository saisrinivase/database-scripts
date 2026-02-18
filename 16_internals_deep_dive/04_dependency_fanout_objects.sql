/*
Purpose: Identify objects with high dependency fanout in catalog metadata.
Area: Internals Deep Dive
Usage: High fanout objects need careful change planning.
*/
SELECT
    c.oid AS object_oid,
    n.nspname AS schema_name,
    c.relname AS object_name,
    c.relkind,
    count(d.objid) AS dependency_count
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
LEFT JOIN pg_depend d
    ON d.refobjid = c.oid
WHERE n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
GROUP BY c.oid, n.nspname, c.relname, c.relkind
ORDER BY dependency_count DESC, schema_name, object_name
LIMIT 200;
