/*
Purpose: Identify applications holding idle transactions that can block cleanup and increase latency.
Area: Application Development and ORM Performance
Usage: Coordinate fixes with transaction scope in application code.
*/
SELECT
    application_name,
    usename AS user_name,
    datname AS database_name,
    count(*) AS idle_in_txn_sessions,
    min(xact_start) AS oldest_xact_start,
    max(now() - xact_start) AS max_xact_age
FROM pg_stat_activity
WHERE state = 'idle in transaction'
GROUP BY application_name, usename, datname
ORDER BY idle_in_txn_sessions DESC, max_xact_age DESC;
