/*
Purpose: Report core performance-related instance settings for baseline tuning.
Area: Configuration Parameters
Usage: Compare across environments to catch drift.
*/
SELECT
    name,
    setting,
    unit,
    source,
    boot_val,
    reset_val
FROM pg_settings
WHERE name IN (
    'shared_buffers',
    'work_mem',
    'maintenance_work_mem',
    'effective_cache_size',
    'effective_io_concurrency',
    'max_worker_processes',
    'max_parallel_workers',
    'max_parallel_workers_per_gather'
)
ORDER BY name;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--               name               | setting | unit |       source       | boot_val | reset_val 
-- ---------------------------------+---------+------+--------------------+----------+-----------
--  effective_cache_size            | 524288  | 8kB  | default            | 524288   | 524288
--  effective_io_concurrency        | 16      |      | default            | 16       | 16
--  maintenance_work_mem            | 65536   | kB   | default            | 65536    | 65536
--  max_parallel_workers            | 8       |      | default            | 8        | 8
--  max_parallel_workers_per_gather | 2       |      | default            | 2        | 2
--  max_worker_processes            | 8       |      | default            | 8        | 8
--  shared_buffers                  | 16384   | 8kB  | configuration file | 16384    | 16384
--  work_mem                        | 4096    | kB   | default            | 4096     | 4096
-- (8 rows)
-- 
-- SAMPLE_OUTPUT_END
