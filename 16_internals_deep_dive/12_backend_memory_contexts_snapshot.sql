/*
PostgreSQL DBA Script: Backend Memory Contexts Snapshot
Purpose: Show current backend memory contexts and server process mix for memory-pressure triage.
Area: Internals Deep Dive
Usage: Use when investigating backend memory growth, work_mem pressure, sort/hash memory, or unexplained process RSS.
Sample Output: First result shows current backend memory contexts; second result summarizes backend types.
Notes: Read-only diagnostic. pg_backend_memory_contexts shows this session only; use it as a shape/reference, not whole-cluster memory.
*/
SELECT
    name AS memory_context,
    ident,
    array_to_string(path, ' > ') AS context_path,
    level,
    total_bytes,
    pg_size_pretty(total_bytes) AS total_pretty,
    free_bytes,
    pg_size_pretty(free_bytes) AS free_pretty,
    used_bytes,
    pg_size_pretty(used_bytes) AS used_pretty,
    CASE
        WHEN used_bytes >= 100::bigint * 1024 * 1024 THEN 'LARGE_CONTEXT_IN_CURRENT_BACKEND'
        WHEN name ILIKE '%TupleSort%' OR name ILIKE '%Hash%' THEN 'SORT_OR_HASH_CONTEXT'
        WHEN name ILIKE '%CacheMemoryContext%' THEN 'CATALOG_CACHE_CONTEXT'
        ELSE 'NORMAL_CONTEXT'
    END AS diagnosis
FROM pg_backend_memory_contexts
ORDER BY used_bytes DESC
LIMIT 80;

SELECT
    backend_type,
    state,
    wait_event_type,
    wait_event,
    count(*) AS sessions,
    max(now() - backend_start) AS oldest_backend_age,
    max(now() - xact_start) FILTER (WHERE xact_start IS NOT NULL) AS oldest_xact_age,
    max(now() - query_start) FILTER (WHERE query_start IS NOT NULL) AS oldest_query_age,
    CASE
        WHEN backend_type = 'client backend' AND state = 'idle in transaction' THEN 'IDLE_TRANSACTION_MEMORY_AND_VACUUM_RISK'
        WHEN backend_type = 'client backend' AND state = 'active' THEN 'ACTIVE_QUERY_MEMORY_REVIEW'
        WHEN backend_type ILIKE '%autovacuum%' THEN 'AUTOVACUUM_WORKER_MEMORY'
        ELSE 'BACKGROUND_OR_IDLE_BACKEND'
    END AS diagnosis,
    CASE
        WHEN backend_type = 'client backend' AND state = 'idle in transaction' THEN 'Close idle transactions; they can hold snapshots and memory while blocking vacuum cleanup.'
        WHEN backend_type = 'client backend' AND state = 'active' THEN 'Correlate with pg_stat_statements temp blocks, work_mem settings, and execution plans.'
        ELSE 'Use OS process RSS plus backend_type to continue memory attribution.'
    END AS action_hint
FROM pg_stat_activity
GROUP BY backend_type, state, wait_event_type, wait_event
ORDER BY sessions DESC, backend_type, state;

-- SAMPLE_OUTPUT_BEGIN
-- memory_context      | total_pretty | used_pretty | diagnosis
-- CacheMemoryContext  | 1024 kB      | 800 kB      | CATALOG_CACHE_CONTEXT
--
-- backend_type   | state  | sessions | diagnosis
-- client backend | active | 5        | ACTIVE_QUERY_MEMORY_REVIEW
-- SAMPLE_OUTPUT_END
