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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--          backend_type         | backend_count 
-- ------------------------------+---------------
--  io worker                    |             3
--  autovacuum launcher          |             1
--  background writer            |             1
--  checkpointer                 |             1
--  client backend               |             1
--  logical replication launcher |             1
--  walwriter                    |             1
-- (7 rows)
-- 
-- SAMPLE_OUTPUT_END
