/*
PostgreSQL DBA Script: Capture WAL Snapshot
Purpose: Capture WAL counter snapshots for WAL rate trend analysis.
Area: Capacity Forecasting
Usage: PostgreSQL 14+; schedule at fixed intervals.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
INSERT INTO dba_metrics.wal_snapshots (
    captured_at,
    wal_records,
    wal_fpi,
    wal_bytes,
    stats_reset
)
SELECT
    now() AS captured_at,
    wal_records,
    wal_fpi,
    wal_bytes,
    stats_reset
FROM pg_stat_wal;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
-- INSERT 0 1
-- SAMPLE_OUTPUT_END
