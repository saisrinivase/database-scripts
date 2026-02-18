/*
Purpose: Compare current connections against role-level connection limits.
Area: Connection and Workload
Usage: Roles with low limits and high utilization are outage risks.
*/
WITH role_conn AS (
    SELECT
        usename AS role_name,
        count(*) AS current_connections
    FROM pg_stat_activity
    GROUP BY usename
)
SELECT
    r.rolname AS role_name,
    r.rolconnlimit,
    coalesce(c.current_connections, 0) AS current_connections,
    CASE
        WHEN r.rolconnlimit < 0 THEN NULL
        ELSE round(100.0 * coalesce(c.current_connections, 0) / NULLIF(r.rolconnlimit, 0), 2)
    END AS pct_of_role_limit
FROM pg_roles r
LEFT JOIN role_conn c
    ON c.role_name = r.rolname
WHERE r.rolcanlogin
ORDER BY pct_of_role_limit DESC NULLS LAST, current_connections DESC;
