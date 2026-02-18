/*
Purpose: Break down active connections by database, user, and application.
Area: Connection and Workload
Usage: Useful for pool sizing and workload attribution.
*/
SELECT
    datname AS database_name,
    usename AS user_name,
    application_name,
    state,
    count(*) AS connection_count
FROM pg_stat_activity
GROUP BY datname, usename, application_name, state
ORDER BY connection_count DESC, datname, usename, application_name;
