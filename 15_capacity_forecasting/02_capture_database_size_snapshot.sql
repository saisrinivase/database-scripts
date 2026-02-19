/*
Purpose: Capture point-in-time database sizes for growth tracking.
Area: Capacity Forecasting
Usage: Schedule daily/hourly after repository creation.
*/
INSERT INTO dba_metrics.database_size_snapshots (captured_at, database_name, size_bytes)
SELECT
    now() AS captured_at,
    datname AS database_name,
    pg_database_size(datname) AS size_bytes
FROM pg_database
WHERE datallowconn;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

INSERT 0 7

SAMPLE_OUTPUT_END */
