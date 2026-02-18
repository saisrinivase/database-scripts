/*
Purpose: Break down main/FSM/VM/TOAST forks to inspect internal storage overhead.
Area: Internals Deep Dive
Usage: Helps explain relation size composition beyond heap/index totals.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    pg_relation_size(c.oid, 'main') AS main_bytes,
    pg_relation_size(c.oid, 'fsm') AS fsm_bytes,
    pg_relation_size(c.oid, 'vm') AS vm_bytes,
    CASE WHEN c.reltoastrelid = 0 THEN 0 ELSE pg_total_relation_size(c.reltoastrelid) END AS toast_total_bytes,
    pg_total_relation_size(c.oid) AS table_total_bytes,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS table_total_pretty
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'm')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY table_total_bytes DESC;
