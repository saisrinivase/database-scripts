/*
Purpose: Capture WAL counter snapshots for WAL rate trend analysis.
Area: Capacity Forecasting
Usage: PostgreSQL 14+; schedule at fixed intervals.
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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

INSERT 0 1

SAMPLE_OUTPUT_END */
