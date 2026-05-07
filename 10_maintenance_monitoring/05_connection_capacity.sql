/*
PostgreSQL DBA Script: Connection Capacity
Purpose: Show connection utilization against max_connections.
Area: Maintenance and Monitoring
Usage: Useful for capacity planning and pool sizing.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  max_connections | total_connections | active_connections | idle_connections | idle_in_txn_connections | pct_used 
-- -----------------+-------------------+--------------------+------------------+-------------------------+----------
--              100 |                 9 |                  1 |                0 |                       0 |     9.00
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
