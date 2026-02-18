/*
Purpose: Capture connection distribution snapshot for pool/capacity trending.
Area: Capacity Forecasting
Usage: Schedule at higher frequency (for example every 5 minutes).
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
