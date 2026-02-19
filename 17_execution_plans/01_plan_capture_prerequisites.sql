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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

            name            |      setting       | unit |       source       | boot_val |     reset_val      
----------------------------+--------------------+------+--------------------+----------+--------------------
 compute_query_id           | auto               |      | default            | auto     | auto
 jit                        | on                 |      | default            | on       | on
 log_min_duration_statement | -1                 | ms   | default            | -1       | -1
 plan_cache_mode            | auto               |      | default            | auto     | auto
 shared_preload_libraries   | pg_stat_statements |      | configuration file |          | pg_stat_statements
 track_activity_query_size  | 1024               | B    | default            | 1024     | 1024
 track_io_timing            | off                |      | default            | off      | off
(7 rows)


SAMPLE_OUTPUT_END */
