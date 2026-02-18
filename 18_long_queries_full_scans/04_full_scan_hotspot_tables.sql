/*
Purpose: Identify large tables where sequential scans dominate access pattern.
Area: Long Queries and Full Scans
Usage: Candidate list for indexing/query rewrite review.
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
