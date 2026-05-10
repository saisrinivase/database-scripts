/*
PostgreSQL DBA Script: Seq Scan Hotspots
Purpose: Highlight tables dominated by sequential scans, explain why they matter, and show what can happen if no action is taken.
Area: Planner and Statistics
Usage: Use when queries are slow, I/O is high, cache hit ratio is low, or CPU rises from repeated table scans. Validate with EXPLAIN before adding indexes because sequential scans can be normal for small tables, broad reports, or queries returning a large share of a table.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic. High sequential scan percentage on a large/highly used table can indicate missing indexes, stale statistics, non-sargable predicates, or query patterns that force full-table reads.
*/
WITH table_scan_stats AS (
    SELECT
        schemaname AS schema_name,
        relname AS table_name,
        relid,
        seq_scan,
        idx_scan,
        n_live_tup,
        n_dead_tup,
        analyze_count,
        autoanalyze_count,
        last_analyze,
        last_autoanalyze,
        pg_total_relation_size(relid) AS total_bytes,
        CASE
            WHEN seq_scan + idx_scan = 0 THEN NULL
            ELSE round(100.0 * seq_scan / (seq_scan + idx_scan), 2)
        END AS seq_scan_pct
    FROM pg_stat_user_tables
)
SELECT
    schema_name,
    table_name,
    seq_scan,
    idx_scan,
    n_live_tup,
    n_dead_tup,
    seq_scan_pct,
    pg_size_pretty(total_bytes) AS total_size,
    analyze_count,
    autoanalyze_count,
    last_analyze,
    last_autoanalyze,
    CASE
        WHEN seq_scan >= 1000
             AND coalesce(seq_scan_pct, 0) >= 80
             AND total_bytes >= 1024::bigint * 1024 * 1024
            THEN 'CRITICAL'
        WHEN seq_scan >= 100
             AND coalesce(seq_scan_pct, 0) >= 70
             AND total_bytes >= 256::bigint * 1024 * 1024
            THEN 'HIGH'
        WHEN seq_scan >= 10
             AND coalesce(seq_scan_pct, 0) >= 50
             AND total_bytes >= 64::bigint * 1024 * 1024
            THEN 'MEDIUM'
        WHEN seq_scan > 0 AND coalesce(seq_scan_pct, 0) >= 80
            THEN 'LOW_REVIEW'
        ELSE 'LOW'
    END AS seq_scan_risk_level,
    CASE
        WHEN seq_scan = 0
            THEN 'No sequential scan pressure recorded since stats reset.'
        WHEN total_bytes < 64::bigint * 1024 * 1024
            THEN 'Sequential scans may be normal because the table is small. Review only if query latency is visible or scans are very frequent.'
        WHEN coalesce(seq_scan_pct, 0) >= 80 AND idx_scan = 0
            THEN 'Table is mostly or entirely read by full scans. If ignored, repeated queries may read the full table, increase I/O, reduce cache efficiency, and slow down as data grows.'
        WHEN coalesce(seq_scan_pct, 0) >= 50
            THEN 'Mixed access pattern with significant full scans. If ignored, workload can become storage-heavy and query latency may grow with table size.'
        ELSE 'Index usage dominates or scan pressure is low. Sequential scans may be expected for broad reporting queries.'
    END AS what_happens_if_ignored,
    CASE
        WHEN seq_scan = 0
            THEN 'No action required from this metric.'
        WHEN total_bytes < 64::bigint * 1024 * 1024
            THEN 'Usually no index action. Confirm with EXPLAIN only if this table appears in slow queries.'
        WHEN last_analyze IS NULL AND last_autoanalyze IS NULL
            THEN 'Run ANALYZE or verify autovacuum/analyze settings, then recheck plans before adding indexes.'
        WHEN coalesce(seq_scan_pct, 0) >= 80 AND idx_scan = 0
            THEN 'Find top SQL touching this table, run EXPLAIN (ANALYZE, BUFFERS), check predicates, and add/adjust indexes only for selective filters or joins.'
        WHEN coalesce(seq_scan_pct, 0) >= 50
            THEN 'Review whether scans are expected reports. If not, inspect missing indexes, stale stats, functions on indexed columns, casts, LIKE patterns, and low-selectivity predicates.'
        ELSE 'Monitor trend and correlate with slow SQL before changing indexes.'
    END AS recommended_action
FROM table_scan_stats
ORDER BY
    CASE
        WHEN seq_scan >= 1000
             AND coalesce(seq_scan_pct, 0) >= 80
             AND total_bytes >= 1024::bigint * 1024 * 1024
            THEN 1
        WHEN seq_scan >= 100
             AND coalesce(seq_scan_pct, 0) >= 70
             AND total_bytes >= 256::bigint * 1024 * 1024
            THEN 2
        WHEN seq_scan >= 10
             AND coalesce(seq_scan_pct, 0) >= 50
             AND total_bytes >= 64::bigint * 1024 * 1024
            THEN 3
        ELSE 4
    END,
    seq_scan DESC,
    seq_scan_pct DESC NULLS LAST;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name | table_name  | seq_scan | idx_scan | n_live_tup | seq_scan_pct | total_size | seq_scan_risk_level | what_happens_if_ignored                         | recommended_action
-- -------------+-------------+----------+----------+------------+--------------+------------+---------------------+-------------------------------------------------+------------------------------
--  public      | big_orders  |     1200 |        0 |    9000000 |       100.00 | 8 GB       | CRITICAL            | Table is mostly or entirely read by full scans...| Find top SQL touching this table...
--  public      | app_events  |       42 |       36 |      80000 |        53.85 | 81 MB      | MEDIUM              | Mixed access pattern with significant full scans | Review whether scans are expected...
--  public      | small_codes |      384 |       33 |        500 |        92.09 | 184 kB     | LOW_REVIEW          | Sequential scans may be normal because small...  | Usually no index action...
-- (3 rows)
-- 
-- SAMPLE_OUTPUT_END
