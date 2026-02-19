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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--       role_name      | rolconnlimit | current_connections | pct_of_role_limit 
-- ---------------------+--------------+---------------------+-------------------
--  saiendla            |           -1 |                   2 |                  
--  postgres            |           -1 |                   0 |                  
--  migration_v2_reader |           -1 |                   0 |                  
-- (3 rows)
-- 
-- SAMPLE_OUTPUT_END
