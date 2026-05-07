/*
PostgreSQL DBA Script: Planner Cost Settings
Purpose: Report planner cost parameters that strongly influence execution plan selection.
Area: Planner and Statistics
Usage: Baseline before/after performance tuning changes.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    name,
    setting,
    unit,
    source,
    reset_val
FROM pg_settings
WHERE name IN (
    'default_statistics_target',
    'random_page_cost',
    'seq_page_cost',
    'cpu_tuple_cost',
    'cpu_index_tuple_cost',
    'cpu_operator_cost',
    'parallel_setup_cost',
    'parallel_tuple_cost',
    'min_parallel_table_scan_size',
    'min_parallel_index_scan_size',
    'effective_cache_size'
)
ORDER BY name;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--              name             | setting | unit | source  | reset_val 
-- ------------------------------+---------+------+---------+-----------
--  cpu_index_tuple_cost         | 0.005   |      | default | 0.005
--  cpu_operator_cost            | 0.0025  |      | default | 0.0025
--  cpu_tuple_cost               | 0.01    |      | default | 0.01
--  default_statistics_target    | 100     |      | default | 100
--  effective_cache_size         | 524288  | 8kB  | default | 524288
--  min_parallel_index_scan_size | 64      | 8kB  | default | 64
--  min_parallel_table_scan_size | 1024    | 8kB  | default | 1024
--  parallel_setup_cost          | 1000    |      | default | 1000
--  parallel_tuple_cost          | 0.1     |      | default | 0.1
--  random_page_cost             | 4       |      | default | 4
--  seq_page_cost                | 1       |      | default | 1
-- (11 rows)
-- 
-- SAMPLE_OUTPUT_END
