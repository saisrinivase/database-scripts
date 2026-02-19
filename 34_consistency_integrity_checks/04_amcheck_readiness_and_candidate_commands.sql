/*
Purpose: Assess amcheck readiness and generate candidate bt_index_check commands for large indexes.
Area: Consistency and Integrity Checks
Usage: Run generated commands in a controlled window; prefer replicas for first pass.
*/
SELECT CASE
           WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'amcheck') THEN 1
           ELSE 0
       END AS has_amcheck
\gset

\if :has_amcheck
SELECT
    n.nspname AS schema_name,
    c.relname AS index_name,
    pg_size_pretty(pg_relation_size(c.oid)) AS index_size,
    format(
        'SELECT bt_index_check(%L::regclass, true);',
        format('%I.%I', n.nspname, c.relname)
    ) AS amcheck_command
FROM pg_class c
JOIN pg_namespace n
  ON n.oid = c.relnamespace
JOIN pg_index i
  ON i.indexrelid = c.oid
JOIN pg_am am
  ON am.oid = c.relam
WHERE c.relkind = 'i'
  AND am.amname = 'btree'
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY pg_relation_size(c.oid) DESC
LIMIT 80;
\else
SELECT
    'amcheck extension is not installed.'::text AS status,
    'Install with: CREATE EXTENSION amcheck; then rerun this script.'::text AS guidance;
\endif


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--                status                |                            guidance                             
-- -------------------------------------+-----------------------------------------------------------------
--  amcheck extension is not installed. | Install with: CREATE EXTENSION amcheck; then rerun this script.
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
