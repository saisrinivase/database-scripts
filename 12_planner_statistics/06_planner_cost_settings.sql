/*
Purpose: Report planner cost parameters that strongly influence execution plan selection.
Area: Planner and Statistics
Usage: Baseline before/after performance tuning changes.
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
