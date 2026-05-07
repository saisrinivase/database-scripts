/*
PostgreSQL DBA Script: Stat View Coverage Check
Purpose: Check whether important PostgreSQL observability views, extensions, and settings are available.
Area: Observability 360
Usage: Run before relying on performance dashboards to understand what signal is enabled or missing.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Some rows are version- or extension-dependent.
*/
WITH required_views AS (
    SELECT *
    FROM (VALUES
        ('pg_stat_activity', 'sessions, waits, query age'),
        ('pg_stat_database', 'database-level transactions, cache, temp, deadlocks'),
        ('pg_stat_bgwriter', 'background writer and pre-17 checkpoint counters'),
        ('pg_stat_checkpointer', 'PostgreSQL 17+ checkpoint counters'),
        ('pg_stat_wal', 'WAL records, bytes, writes, syncs'),
        ('pg_stat_archiver', 'archive success/failure counters'),
        ('pg_stat_replication', 'primary-side streaming standby lag'),
        ('pg_stat_wal_receiver', 'standby-side receive status'),
        ('pg_replication_slots', 'slot lag and WAL retention'),
        ('pg_stat_io', 'PostgreSQL 16+ detailed I/O counters'),
        ('pg_stat_progress_vacuum', 'vacuum progress'),
        ('pg_stat_progress_analyze', 'analyze progress'),
        ('pg_stat_progress_create_index', 'index build progress'),
        ('pg_stat_statements', 'statement-level workload history')
    ) AS v(view_name, why_it_matters)
),
extensions AS (
    SELECT extname, extversion
    FROM pg_extension
)
SELECT 'view' AS check_type,
       view_name AS item,
       CASE WHEN to_regclass('pg_catalog.' || view_name) IS NOT NULL OR to_regclass(view_name) IS NOT NULL THEN 'AVAILABLE' ELSE 'MISSING_OR_VERSION_DEPENDENT' END AS status,
       why_it_matters AS purpose
FROM required_views
UNION ALL
SELECT 'extension',
       'pg_stat_statements',
       CASE WHEN EXISTS (SELECT 1 FROM extensions WHERE extname = 'pg_stat_statements') THEN 'INSTALLED' ELSE 'NOT_INSTALLED_IN_THIS_DATABASE' END,
       'Needed for query-level history, top SQL, and resource attribution.'
UNION ALL
SELECT 'extension',
       'pg_buffercache',
       CASE WHEN EXISTS (SELECT 1 FROM extensions WHERE extname = 'pg_buffercache') THEN 'INSTALLED' ELSE 'OPTIONAL_NOT_INSTALLED' END,
       'Optional deep cache residency analysis.'
UNION ALL
SELECT 'setting',
       'track_io_timing',
       current_setting('track_io_timing'),
       'Needed for read/write timing in pg_stat_database and pg_stat_io.'
UNION ALL
SELECT 'setting',
       'track_wal_io_timing',
       current_setting('track_wal_io_timing', true),
       'Needed for WAL write/sync timing where supported.'
UNION ALL
SELECT 'setting',
       'track_functions',
       current_setting('track_functions'),
       'Needed for function execution timing.'
UNION ALL
SELECT 'setting',
       'shared_preload_libraries',
       current_setting('shared_preload_libraries', true),
       'pg_stat_statements must be preloaded before it can collect statement history.'
ORDER BY check_type, item;

-- SAMPLE_OUTPUT_BEGIN
-- check_type | item                | status                        | purpose
-- -----------+---------------------+-------------------------------+-----------------------------------------
-- extension  | pg_stat_statements  | INSTALLED                     | Needed for query-level history...
-- setting    | track_io_timing     | on                            | Needed for read/write timing...
-- view       | pg_stat_io          | AVAILABLE                     | PostgreSQL 16+ detailed I/O counters
-- SAMPLE_OUTPUT_END
