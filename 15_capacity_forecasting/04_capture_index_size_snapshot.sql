/*
PostgreSQL DBA Script: Capture Index Size Snapshot
Purpose: Capture index size and scan count for index growth/utility trends.
Area: Capacity Forecasting
Usage: Schedule periodically with table snapshot.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
-- INSERT 0 30
-- SAMPLE_OUTPUT_END
