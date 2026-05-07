/*
PostgreSQL DBA Script: Full Scan Hotspot Tables
Purpose: Identify large tables where sequential scans dominate access pattern.
Area: Long Queries and Full Scans
Usage: Candidate list for indexing/query rewrite review.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    s.schemaname AS schema_name,
    s.relname AS table_name,
    s.seq_scan,
    s.idx_scan,
    CASE
        WHEN s.seq_scan + s.idx_scan = 0 THEN NULL
        ELSE round(100.0 * s.seq_scan / (s.seq_scan + s.idx_scan), 2)
    END AS seq_scan_pct,
    pg_total_relation_size(s.relid) AS total_bytes,
    pg_size_pretty(pg_total_relation_size(s.relid)) AS total_pretty,
    s.n_live_tup AS estimated_live_rows
FROM pg_stat_user_tables s
WHERE pg_total_relation_size(s.relid) >= 512::bigint * 1024 * 1024
ORDER BY seq_scan_pct DESC NULLS LAST, total_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name |    table_name    | seq_scan | idx_scan | seq_scan_pct | total_bytes | total_pretty | estimated_live_rows 
-- -------------+------------------+----------+----------+--------------+-------------+--------------+---------------------
--  public      | pgbench_accounts |        2 | 10665646 |         0.00 | 31716564992 | 30 GB        |           200000029
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
