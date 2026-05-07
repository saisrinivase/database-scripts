/*
PostgreSQL DBA Script: Parallel Worker Pressure
Purpose: Inspect parallel worker utilization and leader/worker activity pressure.
Area: Background Processes and Memory Pressure
Usage: High sustained utilization can indicate parallelism bottlenecks or mis-sizing.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH cfg AS (
    SELECT
        current_setting('max_worker_processes')::int AS max_worker_processes,
        current_setting('max_parallel_workers')::int AS max_parallel_workers,
        current_setting('max_parallel_workers_per_gather')::int AS max_parallel_workers_per_gather
),
workers AS (
    SELECT
        count(*) FILTER (WHERE backend_type = 'parallel worker') AS active_parallel_workers,
        count(*) FILTER (WHERE backend_type = 'parallel worker' AND state = 'active') AS active_parallel_workers_running
    FROM pg_stat_activity
)
SELECT
    c.max_worker_processes,
    c.max_parallel_workers,
    c.max_parallel_workers_per_gather,
    w.active_parallel_workers,
    w.active_parallel_workers_running,
    round(
        CASE WHEN c.max_parallel_workers = 0 THEN 0
             ELSE 100.0 * w.active_parallel_workers::numeric / c.max_parallel_workers
        END,
        2
    ) AS parallel_worker_utilization_pct,
    CASE
        WHEN c.max_parallel_workers = 0 THEN 'PARALLEL_DISABLED'
        WHEN w.active_parallel_workers >= c.max_parallel_workers THEN 'SATURATED'
        WHEN w.active_parallel_workers >= c.max_parallel_workers * 0.8 THEN 'HIGH_UTILIZATION'
        ELSE 'AVAILABLE_HEADROOM'
    END AS pressure_label
FROM cfg c
CROSS JOIN workers w;

WITH parallel_activity AS (
    SELECT
        pid,
        leader_pid,
        usename,
        application_name,
        state,
        wait_event_type,
        wait_event,
        round(extract(epoch FROM (clock_timestamp() - query_start))::numeric, 2) AS query_age_seconds,
        left(query, 180) AS query_snippet
    FROM pg_stat_activity
    WHERE backend_type = 'parallel worker'
)
SELECT
    pid,
    leader_pid,
    usename,
    application_name,
    state,
    wait_event_type,
    wait_event,
    query_age_seconds,
    query_snippet
FROM parallel_activity
ORDER BY query_age_seconds DESC, pid;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  max_worker_processes | max_parallel_workers | max_parallel_workers_per_gather | active_parallel_workers | active_parallel_workers_running | parallel_worker_utilization_pct |   pressure_label   
-- ----------------------+----------------------+---------------------------------+-------------------------+---------------------------------+---------------------------------+--------------------
--                     8 |                    8 |                               2 |                       0 |                               0 |                            0.00 | AVAILABLE_HEADROOM
-- (1 row)
-- 
--  pid | leader_pid | usename | application_name | state | wait_event_type | wait_event | query_age_seconds | query_snippet 
-- -----+------------+---------+------------------+-------+-----------------+------------+-------------------+---------------
-- (0 rows)
-- 
-- SAMPLE_OUTPUT_END
