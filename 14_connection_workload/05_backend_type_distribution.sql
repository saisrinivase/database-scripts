/*
Purpose: Show backend process distribution by backend_type.
Area: Connection and Workload
Usage: Distinguish client backends from maintenance/background workers.
*/
SELECT
    backend_type,
    count(*) AS backend_count
FROM pg_stat_activity
GROUP BY backend_type
ORDER BY backend_count DESC, backend_type;
