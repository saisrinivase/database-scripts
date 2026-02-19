/*
Purpose: Show connection and timeout settings that influence application behavior and contention.
Area: Configuration Parameters
Usage: Validate with connection pooling and app retry strategy.
*/
SELECT
    name,
    setting,
    unit,
    source
FROM pg_settings
WHERE name IN (
    'max_connections',
    'superuser_reserved_connections',
    'statement_timeout',
    'lock_timeout',
    'idle_in_transaction_session_timeout',
    'tcp_keepalives_idle',
    'tcp_keepalives_interval',
    'tcp_keepalives_count'
)
ORDER BY name;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--                 name                 | setting | unit |       source       
-- -------------------------------------+---------+------+--------------------
--  idle_in_transaction_session_timeout | 0       | ms   | default
--  lock_timeout                        | 0       | ms   | default
--  max_connections                     | 100     |      | configuration file
--  statement_timeout                   | 0       | ms   | default
--  superuser_reserved_connections      | 3       |      | default
--  tcp_keepalives_count                | 0       |      | default
--  tcp_keepalives_idle                 | 0       | s    | default
--  tcp_keepalives_interval             | 0       | s    | default
-- (8 rows)
-- 
-- SAMPLE_OUTPUT_END
