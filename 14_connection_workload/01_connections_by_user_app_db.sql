/*
PostgreSQL DBA Script: Connections By User App Db
Purpose: Break down active connections by database, user, and application.
Area: Connection and Workload
Usage: Useful for pool sizing and workload attribution.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  database_name | user_name | application_name | state  | connection_count 
-- ---------------+-----------+------------------+--------+------------------
--                |           |                  |        |                7
--  pgbench_test  | saiendla  | psql             | active |                1
--                | saiendla  |                  |        |                1
-- (3 rows)
-- 
-- SAMPLE_OUTPUT_END

