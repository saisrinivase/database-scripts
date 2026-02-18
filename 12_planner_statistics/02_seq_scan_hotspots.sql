/*
Purpose: Highlight tables dominated by sequential scans (possible index or query design issue).
Area: Planner and Statistics
Usage: Validate with query plans before adding indexes.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    seq_scan,
    idx_scan,
    n_live_tup,
    CASE
        WHEN seq_scan + idx_scan = 0 THEN NULL
        ELSE round(100.0 * seq_scan / (seq_scan + idx_scan), 2)
    END AS seq_scan_pct,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
ORDER BY seq_scan DESC, seq_scan_pct DESC NULLS LAST;
