/*
Purpose: Find high-frequency statements violating common OLTP latency expectations.
Area: Optimization Goals (OLTP vs OLAP)
Usage: Tune thresholds to your SLA targets.
*/
SELECT
    queryid,
    calls,
    mean_exec_time,
    total_exec_time,
    rows,
    shared_blks_read,
    temp_blks_written,
    left(query, 260) AS query_snippet
FROM pg_stat_statements
WHERE calls >= 1000
  AND mean_exec_time >= 20
ORDER BY mean_exec_time DESC
LIMIT 200;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  queryid | calls | mean_exec_time | total_exec_time | rows | shared_blks_read | temp_blks_written | query_snippet 
-- ---------+-------+----------------+-----------------+------+------------------+-------------------+---------------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No matching rows were returned at capture time.
-- - Rerun during peak workload or after seeding representative test cases for non-zero examples.
-- SAMPLE_OUTPUT_END
