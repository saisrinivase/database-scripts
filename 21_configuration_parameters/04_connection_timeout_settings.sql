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
