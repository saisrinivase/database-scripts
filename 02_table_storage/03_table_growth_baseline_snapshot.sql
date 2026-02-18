/*
Purpose: Capture current table size and row estimate as a growth baseline snapshot.
Area: Table Storage
Usage: Export results periodically and compare snapshots externally.
*/
SELECT
    now() AS captured_at,
    s.schemaname AS schema_name,
    s.relname AS table_name,
    s.n_live_tup AS estimated_live_rows,
    s.n_dead_tup AS estimated_dead_rows,
    pg_total_relation_size(s.relid) AS total_bytes,
    pg_size_pretty(pg_total_relation_size(s.relid)) AS total_pretty
FROM pg_stat_user_tables s
ORDER BY total_bytes DESC;
