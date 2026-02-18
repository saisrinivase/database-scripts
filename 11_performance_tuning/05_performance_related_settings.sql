/*
Purpose: Show key performance tuning settings in one result set.
Area: Performance Tuning
Usage: Compare across environments for drift and baseline tuning.
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
    'max_connections',
    'shared_buffers',
    'work_mem',
    'maintenance_work_mem',
    'effective_cache_size',
    'effective_io_concurrency',
    'random_page_cost',
    'seq_page_cost',
    'cpu_tuple_cost',
    'cpu_index_tuple_cost',
    'cpu_operator_cost',
    'default_statistics_target',
    'max_parallel_workers',
    'max_parallel_workers_per_gather',
    'max_worker_processes',
    'jit',
    'jit_above_cost',
    'track_io_timing',
    'track_functions'
)
ORDER BY name;
