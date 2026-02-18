/*
Purpose: Capture index size and scan count for index growth/utility trends.
Area: Capacity Forecasting
Usage: Schedule periodically with table snapshot.
*/
INSERT INTO dba_metrics.index_size_snapshots (
    captured_at,
    schema_name,
    table_name,
    index_name,
    index_bytes,
    idx_scan
)
SELECT
    now() AS captured_at,
    s.schemaname AS schema_name,
    s.relname AS table_name,
    s.indexrelname AS index_name,
    pg_relation_size(s.indexrelid) AS index_bytes,
    s.idx_scan
FROM pg_stat_user_indexes s;
