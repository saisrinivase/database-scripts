/*
Purpose: Measure connection saturation and queue-risk proxy metrics from PostgreSQL side.
Area: Pooler and Proxy Diagnostics
Usage: High client-backend saturation often indicates pool sizing or connection churn issues.
*/
WITH cfg AS (
    SELECT
        current_setting('max_connections')::int AS max_connections,
        coalesce(nullif(current_setting('superuser_reserved_connections', true), ''), '0')::int AS superuser_reserved_connections,
        coalesce(nullif(current_setting('reserved_connections', true), ''), '0')::int AS reserved_connections
),
act AS (
    SELECT
        count(*) AS total_backends,
        count(*) FILTER (WHERE backend_type = 'client backend') AS client_backends,
        count(*) FILTER (WHERE backend_type = 'client backend' AND state = 'active') AS active_client_backends,
        count(*) FILTER (WHERE backend_type = 'client backend' AND state = 'idle') AS idle_client_backends,
        count(*) FILTER (WHERE backend_type = 'client backend' AND state = 'idle in transaction') AS idle_in_tx_client_backends
    FROM pg_stat_activity
)
SELECT
    c.max_connections,
    c.superuser_reserved_connections,
    c.reserved_connections,
    (c.max_connections - c.superuser_reserved_connections - c.reserved_connections) AS effective_client_slots,
    a.total_backends,
    a.client_backends,
    a.active_client_backends,
    a.idle_client_backends,
    a.idle_in_tx_client_backends,
    round(
        CASE WHEN c.max_connections = 0 THEN 0
             ELSE 100.0 * a.client_backends::numeric / c.max_connections
        END,
        2
    ) AS client_backend_utilization_pct,
    CASE
        WHEN a.client_backends >= (c.max_connections - c.superuser_reserved_connections - c.reserved_connections) THEN 'SATURATED'
        WHEN a.client_backends >= (c.max_connections * 0.85) THEN 'HIGH_UTILIZATION'
        WHEN a.idle_client_backends > a.active_client_backends * 2 THEN 'IDLE_HEAVY_CONNECTION_PATTERN'
        ELSE 'HEALTHY_HEADROOM'
    END AS pool_risk_label,
    CASE
        WHEN a.idle_in_tx_client_backends > 0 THEN 'Investigate idle-in-transaction sessions; they hold locks and pins.'
        WHEN a.client_backends >= (c.max_connections * 0.85) THEN 'Check pool queue depth and pooling mode in external pooler.'
        ELSE 'No urgent saturation signal.'
    END AS action_hint
FROM cfg c
CROSS JOIN act a;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  max_connections | superuser_reserved_connections | reserved_connections | effective_client_slots | total_backends | client_backends | active_client_backends | idle_client_backends | idle_in_tx_client_backends | client_backend_utilization_pct | pool_risk_label  |         action_hint          
-- -----------------+--------------------------------+----------------------+------------------------+----------------+-----------------+------------------------+----------------------+----------------------------+--------------------------------+------------------+------------------------------
--              100 |                              3 |                    0 |                     97 |              9 |               1 |                      1 |                    0 |                          0 |                           1.00 | HEALTHY_HEADROOM | No urgent saturation signal.
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END

