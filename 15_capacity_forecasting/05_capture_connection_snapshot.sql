/*
PostgreSQL DBA Script: Capture Connection Snapshot
Purpose: Capture connection distribution snapshot for pool/capacity trending.
Area: Capacity Forecasting
Usage: Schedule at higher frequency (for example every 5 minutes).
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
INSERT INTO dba_metrics.connection_snapshots (
    captured_at,
    database_name,
    user_name,
    application_name,
    state,
    connection_count
)
SELECT
    now() AS captured_at,
    datname AS database_name,
    usename AS user_name,
    application_name,
    state,
    count(*)::int AS connection_count
FROM pg_stat_activity
GROUP BY datname, usename, application_name, state;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
-- INSERT 0 3
-- SAMPLE_OUTPUT_END
