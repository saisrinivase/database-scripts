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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

              name               | setting | unit |       source       | boot_val | reset_val 
---------------------------------+---------+------+--------------------+----------+-----------
 cpu_index_tuple_cost            | 0.005   |      | default            | 0.005    | 0.005
 cpu_operator_cost               | 0.0025  |      | default            | 0.0025   | 0.0025
 cpu_tuple_cost                  | 0.01    |      | default            | 0.01     | 0.01
 default_statistics_target       | 100     |      | default            | 100      | 100
 effective_cache_size            | 524288  | 8kB  | default            | 524288   | 524288
 effective_io_concurrency        | 16      |      | default            | 16       | 16
 jit                             | on      |      | default            | on       | on
 jit_above_cost                  | 100000  |      | default            | 100000   | 100000
 maintenance_work_mem            | 65536   | kB   | default            | 65536    | 65536
 max_connections                 | 100     |      | configuration file | 100      | 100
 max_parallel_workers            | 8       |      | default            | 8        | 8
 max_parallel_workers_per_gather | 2       |      | default            | 2        | 2
 max_worker_processes            | 8       |      | default            | 8        | 8
 random_page_cost                | 4       |      | default            | 4        | 4
 seq_page_cost                   | 1       |      | default            | 1        | 1
 shared_buffers                  | 16384   | 8kB  | configuration file | 16384    | 16384
 track_functions                 | none    |      | default            | none     | none
 track_io_timing                 | off     |      | default            | off      | off
 work_mem                        | 4096    | kB   | default            | 4096     | 4096
(19 rows)


SAMPLE_OUTPUT_END */
