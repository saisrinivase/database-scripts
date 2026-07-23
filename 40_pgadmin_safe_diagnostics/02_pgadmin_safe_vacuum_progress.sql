/*
PostgreSQL DBA Script: PgAdmin Safe Vacuum Progress
Purpose: Monitor running VACUUM operations using columns available across PostgreSQL 15-18.
Area: PgAdmin Safe Diagnostics
Usage: Run directly in pgAdmin Query Tool.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Uses common pg_stat_progress_vacuum columns so no psql version branching is needed.
*/
SELECT
    p.pid,
    n.nspname AS schema_name,
    c.relname AS table_name,
    p.phase,
    p.heap_blks_total,
    p.heap_blks_scanned,
    p.heap_blks_vacuumed,
    round(100.0 * p.heap_blks_scanned / NULLIF(p.heap_blks_total, 0), 2) AS heap_scan_pct,
    p.index_vacuum_count,
    a.backend_type,
    a.wait_event_type,
    a.wait_event,
    now() - a.query_start AS query_age,
    regexp_replace(a.query, '\s+', ' ', 'g') AS query_sample
FROM pg_stat_progress_vacuum p
JOIN pg_class c ON c.oid = p.relid
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_stat_activity a ON a.pid = p.pid
ORDER BY p.pid;

-- SAMPLE_OUTPUT_BEGIN
-- pid | schema_name | table_name | phase | heap_blks_total | heap_scan_pct | wait_event_type
-- ----+-------------+------------+-------+-----------------+---------------+----------------
-- (0 rows)
-- SAMPLE_OUTPUT_END
