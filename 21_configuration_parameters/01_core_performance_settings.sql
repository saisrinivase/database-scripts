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
