/*
Purpose: Monitor currently running VACUUM operations.
Area: Vacuum and Bloat
Usage: Requires PostgreSQL with pg_stat_progress_vacuum view.
*/
SELECT (current_setting('server_version_num')::int >= 170000) AS has_vacuum_bytes \gset

\if :has_vacuum_bytes
SELECT
    p.pid,
    n.nspname AS schema_name,
    c.relname AS table_name,
    p.phase,
    p.heap_blks_total,
    p.heap_blks_scanned,
    p.heap_blks_vacuumed,
    p.index_vacuum_count,
    p.max_dead_tuple_bytes,
    p.dead_tuple_bytes,
    p.num_dead_item_ids
FROM pg_stat_progress_vacuum p
JOIN pg_class c
    ON c.oid = p.relid
JOIN pg_namespace n
    ON n.oid = c.relnamespace
ORDER BY p.pid;
\else
SELECT
    p.pid,
    n.nspname AS schema_name,
    c.relname AS table_name,
    p.phase,
    p.heap_blks_total,
    p.heap_blks_scanned,
    p.heap_blks_vacuumed,
    p.index_vacuum_count,
    p.max_dead_tuples,
    p.num_dead_tuples
FROM pg_stat_progress_vacuum p
JOIN pg_class c
    ON c.oid = p.relid
JOIN pg_namespace n
    ON n.oid = c.relnamespace
ORDER BY p.pid;
\endif




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  pid | schema_name | table_name | phase | heap_blks_total | heap_blks_scanned | heap_blks_vacuumed | index_vacuum_count | max_dead_tuple_bytes | dead_tuple_bytes | num_dead_item_ids 
-- -----+-------------+------------+-------+-----------------+-------------------+--------------------+--------------------+----------------------+------------------+-------------------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No matching rows were returned at capture time.
-- - Rerun during peak workload or after seeding representative test cases for non-zero examples.
-- SAMPLE_OUTPUT_END
