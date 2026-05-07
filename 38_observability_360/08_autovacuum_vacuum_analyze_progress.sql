/*
PostgreSQL DBA Script: Autovacuum Vacuum Analyze Progress
Purpose: Show current vacuum/analyze progress and tables with the largest cleanup/analyze backlog.
Area: Observability 360
Usage: Run when bloat, stale statistics, wraparound, or autovacuum pressure is suspected.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Progress views show currently running work only.
*/
SELECT
    'running_vacuum' AS section,
    p.pid,
    p.datname AS database_name,
    p.relid::regclass::text AS relation_name,
    p.phase,
    p.heap_blks_total,
    p.heap_blks_scanned,
    p.heap_blks_vacuumed,
    round(100.0 * p.heap_blks_scanned / NULLIF(p.heap_blks_total, 0), 2) AS scan_pct,
    p.index_vacuum_count,
    a.backend_type,
    a.wait_event_type,
    a.wait_event,
    now() - a.query_start AS query_age
FROM pg_stat_progress_vacuum p
LEFT JOIN pg_stat_activity a ON a.pid = p.pid
ORDER BY query_age DESC NULLS LAST;

SELECT
    'running_analyze' AS section,
    p.pid,
    p.datname AS database_name,
    p.relid::regclass::text AS relation_name,
    p.phase,
    a.backend_type,
    a.wait_event_type,
    a.wait_event,
    now() - a.query_start AS query_age
FROM pg_stat_progress_analyze p
LEFT JOIN pg_stat_activity a ON a.pid = p.pid
ORDER BY query_age DESC NULLS LAST;

SELECT
    'autovacuum_backlog' AS section,
    schemaname,
    relname AS table_name,
    n_live_tup,
    n_dead_tup,
    round(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_tuple_pct,
    n_mod_since_analyze,
    vacuum_count,
    autovacuum_count,
    analyze_count,
    autoanalyze_count,
    last_autovacuum,
    last_autoanalyze
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC, n_mod_since_analyze DESC
LIMIT 50;

-- SAMPLE_OUTPUT_BEGIN
-- section            | database_name | relation_name | phase              | scan_pct | query_age
-- -------------------+---------------+---------------+--------------------+----------+----------
-- running_vacuum     | appdb         | public.orders | scanning heap      |    73.44 | 00:02:18
--
-- section            | schemaname | table_name | n_live_tup | n_dead_tup | dead_tuple_pct | n_mod_since_analyze
-- -------------------+------------+------------+------------+------------+----------------+--------------------
-- autovacuum_backlog | public     | events     | 310000000  | 62000000   |          16.67 |           8932110
-- SAMPLE_OUTPUT_END
