/*
PostgreSQL DBA Script: Connection Distribution By App User
Purpose: Show connection distribution by user/application/client for pool right-sizing and hotspot detection.
Area: Pooler and Proxy Diagnostics
Usage: Look for many idle sessions per app/user and bursty client patterns.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    usename,
    coalesce(nullif(application_name, ''), '(unknown_app)') AS application_name,
    coalesce(client_addr::text, '(local)') AS client_addr,
    count(*) AS total_sessions,
    count(*) FILTER (WHERE state = 'active') AS active_sessions,
    count(*) FILTER (WHERE state = 'idle') AS idle_sessions,
    count(*) FILTER (WHERE state = 'idle in transaction') AS idle_in_tx_sessions,
    round(avg(extract(epoch FROM (clock_timestamp() - backend_start)))::numeric, 2) AS avg_session_age_seconds,
    round(max(extract(epoch FROM (clock_timestamp() - backend_start)))::numeric, 2) AS max_session_age_seconds,
    CASE
        WHEN count(*) FILTER (WHERE state = 'idle') >= 50 THEN 'HIGH_IDLE_POOL_FOOTPRINT'
        WHEN count(*) FILTER (WHERE state = 'idle in transaction') > 0 THEN 'IDLE_IN_TX_RISK'
        ELSE 'NORMAL'
    END AS pattern_label
FROM pg_stat_activity
WHERE backend_type = 'client backend'
GROUP BY usename, coalesce(nullif(application_name, ''), '(unknown_app)'), coalesce(client_addr::text, '(local)')
ORDER BY total_sessions DESC, idle_sessions DESC
LIMIT 120;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  usename  | application_name | client_addr | total_sessions | active_sessions | idle_sessions | idle_in_tx_sessions | avg_session_age_seconds | max_session_age_seconds | pattern_label 
-- ----------+------------------+-------------+----------------+-----------------+---------------+---------------------+-------------------------+-------------------------+---------------
--  saiendla | psql             | (local)     |              1 |               1 |             0 |                   0 |                    0.02 |                    0.02 | NORMAL
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
