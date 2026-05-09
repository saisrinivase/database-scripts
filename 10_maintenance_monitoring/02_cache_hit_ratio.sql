/*
PostgreSQL DBA Script: Cache Hit Ratio
Purpose: Calculate table/index cache hit ratios, explain performance impact, and recommend next diagnostic actions.
Area: Maintenance and Monitoring
Usage: Use when users report slow queries, high disk I/O, storage latency, or memory pressure. Low cache hit ratio means more blocks are being read from storage instead of PostgreSQL/shared OS cache, which can increase query latency and amplify I/O cost. OLTP systems commonly aim for 99%+ table/index cache hit, mixed workloads often tolerate 95-99%, and analytical/ETL workloads can be lower during large scans.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic. Interpret with workload context: one large reporting scan can lower the ratio without meaning the system is misconfigured.
*/
WITH table_io AS (
    SELECT
        coalesce(sum(heap_blks_read), 0) AS heap_read,
        coalesce(sum(heap_blks_hit), 0) AS heap_hit,
        coalesce(sum(idx_blks_read), 0) AS idx_read,
        coalesce(sum(idx_blks_hit), 0) AS idx_hit
    FROM pg_statio_user_tables
),
index_io AS (
    SELECT
        coalesce(sum(idx_blks_read), 0) AS idx_read,
        coalesce(sum(idx_blks_hit), 0) AS idx_hit
    FROM pg_statio_user_indexes
),
cache AS (
    SELECT
        table_io.heap_read,
        table_io.heap_hit,
        table_io.idx_read + index_io.idx_read AS index_read,
        table_io.idx_hit + index_io.idx_hit AS index_hit,
        round(100.0 * table_io.heap_hit / NULLIF(table_io.heap_hit + table_io.heap_read, 0), 2) AS table_cache_hit_pct,
        round(100.0 * (table_io.idx_hit + index_io.idx_hit) /
              NULLIF(table_io.idx_hit + table_io.idx_read + index_io.idx_hit + index_io.idx_read, 0), 2) AS index_cache_hit_pct
    FROM table_io
    CROSS JOIN index_io
)
SELECT
    table_cache_hit_pct,
    index_cache_hit_pct,
    heap_read AS table_blocks_read_from_disk,
    heap_hit AS table_blocks_hit_in_cache,
    index_read AS index_blocks_read_from_disk,
    index_hit AS index_blocks_hit_in_cache,
    pg_size_pretty((heap_read * current_setting('block_size')::bigint)) AS table_disk_read_volume,
    pg_size_pretty((index_read * current_setting('block_size')::bigint)) AS index_disk_read_volume,
    CASE
        WHEN coalesce(table_cache_hit_pct, 100) < 90 OR coalesce(index_cache_hit_pct, 100) < 90
            THEN 'CRITICAL'
        WHEN coalesce(table_cache_hit_pct, 100) < 95 OR coalesce(index_cache_hit_pct, 100) < 95
            THEN 'HIGH'
        WHEN coalesce(table_cache_hit_pct, 100) < 99 OR coalesce(index_cache_hit_pct, 100) < 99
            THEN 'MEDIUM'
        ELSE 'LOW'
    END AS cache_risk_level,
    CASE
        WHEN coalesce(table_cache_hit_pct, 100) < 90 OR coalesce(index_cache_hit_pct, 100) < 90
            THEN 'Very low cache hit ratio. Expect storage reads to dominate some workloads; users may see slow queries, high read latency, and I/O saturation.'
        WHEN coalesce(table_cache_hit_pct, 100) < 95 OR coalesce(index_cache_hit_pct, 100) < 95
            THEN 'Low cache hit ratio. Mixed workloads may be acceptable, but OLTP systems can suffer from extra disk reads and unstable response time.'
        WHEN coalesce(table_cache_hit_pct, 100) < 99 OR coalesce(index_cache_hit_pct, 100) < 99
            THEN 'Moderate cache miss rate. Usually worth checking for full scans, cold indexes, large reports, or working set larger than memory.'
        ELSE 'Healthy cache ratio for most OLTP workloads. Continue monitoring and correlate only if users report latency.'
    END AS why_this_matters,
    CASE
        WHEN coalesce(table_cache_hit_pct, 100) < 90 OR coalesce(index_cache_hit_pct, 100) < 90
            THEN 'Immediate diagnosis: check top read-heavy SQL, full table scans, missing indexes, pg_stat_io/storage latency, shared_buffers, OS memory, and recent reporting/ETL jobs.'
        WHEN coalesce(table_cache_hit_pct, 100) < 95 OR coalesce(index_cache_hit_pct, 100) < 95
            THEN 'Investigate: rank table/index read pressure, check query plans for sequential scans, validate indexes/statistics, and compare with storage latency metrics.'
        WHEN coalesce(table_cache_hit_pct, 100) < 99 OR coalesce(index_cache_hit_pct, 100) < 99
            THEN 'Review trend: confirm whether misses come from normal large scans or from frequently executed OLTP queries needing tuning.'
        ELSE 'No immediate action. Use this as a baseline and revisit if read latency, IOPS, or query time increases.'
    END AS recommended_action,
    'Helpful follow-ups: 13_io_wal_checkpoints/01_database_io_profile.sql, 11_performance_tuning/04_io_bound_query_candidates.sql, 03_index_analysis/02_unused_indexes_candidates.sql, 18_long_queries_full_scans/04_full_scan_hotspot_tables.sql' AS followup_scripts
FROM cache;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  table_cache_hit_pct | index_cache_hit_pct | table_blocks_read_from_disk | index_blocks_read_from_disk | table_disk_read_volume | index_disk_read_volume | cache_risk_level | why_this_matters                                      | recommended_action
-- ---------------------+---------------------+-----------------------------+-----------------------------+------------------------+------------------------+------------------+-------------------------------------------------------+------------------------------
--                92.02 |               99.36 |                      237905 |                       44930 | 1859 MB                | 351 MB                 | HIGH             | Low cache hit ratio. Mixed workloads may be...        | Investigate: rank table/index...
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
