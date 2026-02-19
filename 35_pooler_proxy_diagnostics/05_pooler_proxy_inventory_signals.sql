/*
Purpose: Inventory pooler/proxy related extensions, FDWs, and operational signals.
Area: Pooler and Proxy Diagnostics
Usage: Use as a bridge between PostgreSQL evidence and external pooler dashboards.
*/
WITH ext AS (
    SELECT
        extname,
        extversion
    FROM pg_extension
    WHERE extname ~* 'pgbouncer|pgpool|odyssey|rds|proxy'
),
fdw AS (
    SELECT
        fs.srvname,
        f.fdwname,
        fs.srvoptions
    FROM pg_foreign_server fs
    JOIN pg_foreign_data_wrapper f
      ON f.oid = fs.srvfdw
),
activity AS (
    SELECT
        count(*) FILTER (WHERE backend_type = 'client backend') AS client_backends,
        count(*) FILTER (WHERE backend_type = 'client backend' AND state = 'active') AS active_client_backends,
        count(*) FILTER (WHERE backend_type = 'client backend' AND state = 'idle') AS idle_client_backends
    FROM pg_stat_activity
)
SELECT
    current_database() AS database_name,
    a.client_backends,
    a.active_client_backends,
    a.idle_client_backends,
    (SELECT count(*) FROM ext) AS proxy_related_extensions,
    (SELECT count(*) FROM fdw) AS foreign_server_count,
    CASE
        WHEN a.client_backends > current_setting('max_connections')::int * 0.9 THEN 'DB_CONNECTION_PRESSURE_HIGH'
        WHEN a.idle_client_backends > a.active_client_backends * 2 THEN 'POSSIBLE_POOL_OVERSIZING_OR_CHURN'
        ELSE 'NO_STRONG_POOLER_SIGNAL'
    END AS primary_signal,
    'Cross-check with pooler admin metrics: wait time, queue depth, server_conn/client_conn ratios.' AS external_validation_note
FROM activity a;

SELECT
    extname,
    extversion
FROM pg_extension
WHERE extname ~* 'pgbouncer|pgpool|odyssey|rds|proxy'
ORDER BY extname;

SELECT
    fs.srvname,
    f.fdwname,
    fs.srvoptions
FROM pg_foreign_server fs
JOIN pg_foreign_data_wrapper f
  ON f.oid = fs.srvfdw
ORDER BY fs.srvname;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh2
--
--  database_name | client_backends | active_client_backends | idle_client_backends | proxy_related_extensions | foreign_server_count |     primary_signal      |                                    external_validation_note                                    
-- ---------------+-----------------+------------------------+----------------------+--------------------------+----------------------+-------------------------+------------------------------------------------------------------------------------------------
--  pgbench_test  |               1 |                      1 |                    0 |                        0 |                    0 | NO_STRONG_POOLER_SIGNAL | Cross-check with pooler admin metrics: wait time, queue depth, server_conn/client_conn ratios.
-- (1 row)
-- 
--  extname | extversion 
-- ---------+------------
-- (0 rows)
-- 
--  srvname | fdwname | srvoptions 
-- ---------+---------+------------
-- (0 rows)
-- 
-- SAMPLE_OUTPUT_END
