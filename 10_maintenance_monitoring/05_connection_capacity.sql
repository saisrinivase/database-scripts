/*
Purpose: Show connection utilization against max_connections.
Area: Maintenance and Monitoring
Usage: Useful for capacity planning and pool sizing.
*/
WITH cfg AS (
    SELECT current_setting('max_connections')::int AS max_connections
),
act AS (
    SELECT
        count(*) AS total_connections,
        count(*) FILTER (WHERE state = 'active') AS active_connections,
        count(*) FILTER (WHERE state = 'idle') AS idle_connections,
        count(*) FILTER (WHERE state = 'idle in transaction') AS idle_in_txn_connections
    FROM pg_stat_activity
)
SELECT
    cfg.max_connections,
    act.total_connections,
    act.active_connections,
    act.idle_connections,
    act.idle_in_txn_connections,
    round(100.0 * act.total_connections / NULLIF(cfg.max_connections, 0), 2) AS pct_used
FROM cfg
CROSS JOIN act;
