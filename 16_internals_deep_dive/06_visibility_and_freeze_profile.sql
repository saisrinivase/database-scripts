/*
Purpose: Correlate visibility/freeze internals for table aging and maintenance planning.
Area: Internals Deep Dive
Usage: Compare with autovacuum settings and freeze thresholds.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    c.relfrozenxid,
    age(c.relfrozenxid) AS relfrozenxid_age,
    c.relminmxid,
    mxid_age(c.relminmxid) AS relminmxid_age,
    c.relpages,
    c.reltuples,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'm')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY relfrozenxid_age DESC;
