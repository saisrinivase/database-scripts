/*
Purpose: Verify settings required for reliable plan analysis and plan-related diagnostics.
Area: Execution Plans
Usage: Run before plan troubleshooting; check values against standards.
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
    'shared_preload_libraries',
    'compute_query_id',
    'track_io_timing',
    'track_activity_query_size',
    'jit',
    'log_min_duration_statement',
    'plan_cache_mode'
)
ORDER BY name;
