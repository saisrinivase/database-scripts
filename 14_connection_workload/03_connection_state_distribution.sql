/*
PostgreSQL DBA Script: Connection State Distribution
Purpose: Summarize session states and average age per state.
Area: Connection and Workload
Usage: Detect excessive idle or long-running active workloads.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    state,
    count(*) AS session_count,
    min(query_start) AS oldest_query_start,
    max(query_start) AS newest_query_start,
    avg(extract(epoch FROM (now() - query_start))) FILTER (WHERE query_start IS NOT NULL) AS avg_query_age_seconds
FROM pg_stat_activity
GROUP BY state
ORDER BY session_count DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  state  | session_count |      oldest_query_start      |      newest_query_start      | avg_query_age_seconds  
-- --------+---------------+------------------------------+------------------------------+------------------------
--         |             8 |                              |                              |                       
--  active |             1 | 2026-02-18 19:43:32.09865-05 | 2026-02-18 19:43:32.09865-05 | 0.00000000000000000000
-- (2 rows)
-- 
-- SAMPLE_OUTPUT_END
