/*
PostgreSQL DBA Script: Cache Hit Ratio
Purpose: Calculate cache hit ratios for tables and indexes.
Area: Maintenance and Monitoring
Usage: Very low hit ratios may indicate memory or query pattern issues.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH table_io AS (
    SELECT
        sum(heap_blks_read) AS heap_read,
        sum(heap_blks_hit) AS heap_hit,
        sum(idx_blks_read) AS idx_read,
        sum(idx_blks_hit) AS idx_hit
    FROM pg_statio_user_tables
),
index_io AS (
    SELECT
        sum(idx_blks_read) AS idx_read,
        sum(idx_blks_hit) AS idx_hit
    FROM pg_statio_user_indexes
)
SELECT
    round(100.0 * heap_hit / NULLIF(heap_hit + heap_read, 0), 2) AS table_cache_hit_pct,
    round(100.0 * (table_io.idx_hit + coalesce(index_io.idx_hit, 0)) /
          NULLIF(table_io.idx_hit + table_io.idx_read + coalesce(index_io.idx_hit, 0) + coalesce(index_io.idx_read, 0), 0), 2) AS index_cache_hit_pct
FROM table_io
CROSS JOIN index_io;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  table_cache_hit_pct | index_cache_hit_pct 
-- ---------------------+---------------------
--                89.26 |               93.38
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
