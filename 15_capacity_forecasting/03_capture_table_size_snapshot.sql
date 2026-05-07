/*
PostgreSQL DBA Script: Capture Table Size Snapshot
Purpose: Capture table-level size and tuple estimates for growth trending.
Area: Capacity Forecasting
Usage: Schedule periodically; can be heavy on very large catalogs.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
INSERT INTO dba_metrics.table_size_snapshots (
    captured_at,
    schema_name,
    table_name,
    total_bytes,
    estimated_live_rows,
    estimated_dead_rows
)
SELECT
    now() AS captured_at,
    s.schemaname AS schema_name,
    s.relname AS table_name,
    pg_total_relation_size(s.relid) AS total_bytes,
    s.n_live_tup AS estimated_live_rows,
    s.n_dead_tup AS estimated_dead_rows
FROM pg_stat_user_tables s;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
-- INSERT 0 32
-- SAMPLE_OUTPUT_END
