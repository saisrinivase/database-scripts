/*
Purpose: Evaluate key performance parameters and output tuning recommendations with severity.
Area: High Speed Tuning
Usage: Advisory output; validate recommendations with workload tests before applying.
*/
WITH vals AS (
    SELECT
        (SELECT setting::int FROM pg_settings WHERE name = 'max_connections') AS max_connections,
        pg_size_bytes((SELECT setting || unit FROM pg_settings WHERE name = 'shared_buffers')) AS shared_buffers_bytes,
        pg_size_bytes((SELECT setting || unit FROM pg_settings WHERE name = 'work_mem')) AS work_mem_bytes,
        pg_size_bytes((SELECT setting || unit FROM pg_settings WHERE name = 'effective_cache_size')) AS effective_cache_bytes,
        pg_size_bytes((SELECT setting || unit FROM pg_settings WHERE name = 'maintenance_work_mem')) AS maintenance_work_mem_bytes,
        pg_size_bytes((SELECT setting || unit FROM pg_settings WHERE name = 'max_wal_size')) AS max_wal_size_bytes,
        (SELECT setting::numeric FROM pg_settings WHERE name = 'checkpoint_completion_target') AS checkpoint_completion_target,
        (SELECT setting::numeric FROM pg_settings WHERE name = 'random_page_cost') AS random_page_cost,
        (SELECT setting FROM pg_settings WHERE name = 'autovacuum') AS autovacuum,
        (SELECT setting FROM pg_settings WHERE name = 'track_io_timing') AS track_io_timing,
        (SELECT setting::int FROM pg_settings WHERE name = 'max_parallel_workers') AS max_parallel_workers,
        (SELECT setting::int FROM pg_settings WHERE name = 'max_parallel_workers_per_gather') AS max_parallel_workers_per_gather,
        (SELECT setting FROM pg_settings WHERE name = 'jit') AS jit
)
SELECT
    parameter,
    current_value,
    severity,
    finding,
    recommendation
FROM (
    SELECT
        'max_connections' AS parameter,
        max_connections::text AS current_value,
        CASE WHEN max_connections > 500 THEN 'high' WHEN max_connections > 300 THEN 'medium' ELSE 'ok' END AS severity,
        'Too many direct connections can reduce throughput and increase context switching.' AS finding,
        'Use a connection pool; target lower active backend count for OLTP.' AS recommendation
    FROM vals

    UNION ALL

    SELECT
        'shared_buffers',
        pg_size_pretty(shared_buffers_bytes),
        CASE WHEN shared_buffers_bytes < 256::bigint * 1024 * 1024 THEN 'high' WHEN shared_buffers_bytes < 1024::bigint * 1024 * 1024 THEN 'medium' ELSE 'ok' END,
        'Low shared_buffers can increase physical reads.',
        'For dedicated DB hosts, start around 15-30% of RAM and validate with cache hit and latency.'
    FROM vals

    UNION ALL

    SELECT
        'work_mem',
        pg_size_pretty(work_mem_bytes),
        CASE WHEN work_mem_bytes < 4::bigint * 1024 * 1024 THEN 'high' WHEN work_mem_bytes < 16::bigint * 1024 * 1024 THEN 'medium' ELSE 'ok' END,
        'Low work_mem increases sort/hash spill risk (temp files).',
        'Increase carefully per workload; remember it is per operation, per backend.'
    FROM vals

    UNION ALL

    SELECT
        'effective_cache_size',
        pg_size_pretty(effective_cache_bytes),
        CASE WHEN effective_cache_bytes < shared_buffers_bytes * 2 THEN 'medium' ELSE 'ok' END,
        'Too-low effective_cache_size can bias planner away from index plans.',
        'Set roughly to OS cache + shared_buffers visible to PostgreSQL.'
    FROM vals

    UNION ALL

    SELECT
        'max_wal_size',
        pg_size_pretty(max_wal_size_bytes),
        CASE WHEN max_wal_size_bytes < 4::bigint * 1024 * 1024 * 1024 THEN 'medium' ELSE 'ok' END,
        'Low max_wal_size can force frequent checkpoints and write pressure.',
        'Increase max_wal_size and review checkpoint metrics.'
    FROM vals

    UNION ALL

    SELECT
        'checkpoint_completion_target',
        checkpoint_completion_target::text,
        CASE WHEN checkpoint_completion_target < 0.7 THEN 'medium' ELSE 'ok' END,
        'Low target can create bursty checkpoint I/O.',
        'Use around 0.7-0.9 for smoother write profile.'
    FROM vals

    UNION ALL

    SELECT
        'random_page_cost',
        random_page_cost::text,
        CASE WHEN random_page_cost > 2.5 THEN 'medium' ELSE 'ok' END,
        'High random_page_cost may discourage useful index scans on SSD/cloud storage.',
        'Benchmark lower values (for example 1.1-2.0) in staging before production.'
    FROM vals

    UNION ALL

    SELECT
        'autovacuum',
        autovacuum,
        CASE WHEN autovacuum = 'off' THEN 'high' ELSE 'ok' END,
        'Autovacuum is required to control bloat and transaction age.',
        'Keep autovacuum enabled and tune thresholds/scales by table size and write rate.'
    FROM vals

    UNION ALL

    SELECT
        'track_io_timing',
        track_io_timing,
        CASE WHEN track_io_timing = 'off' THEN 'medium' ELSE 'ok' END,
        'Without I/O timing, root-cause analysis of storage bottlenecks is limited.',
        'Enable track_io_timing for better performance diagnostics.'
    FROM vals

    UNION ALL

    SELECT
        'parallel_workers',
        format('max_parallel_workers=%s, per_gather=%s', max_parallel_workers, max_parallel_workers_per_gather),
        CASE WHEN max_parallel_workers = 0 THEN 'medium' ELSE 'ok' END,
        'No parallel workers can slow analytical scans and aggregations.',
        'Enable and tune parallel workers for OLAP/reporting workloads.'
    FROM vals

    UNION ALL

    SELECT
        'jit',
        jit,
        CASE WHEN jit = 'on' THEN 'ok' ELSE 'observe' END,
        'JIT may help CPU-heavy long queries but can hurt very short OLTP queries.',
        'Evaluate JIT effect by workload class (OLTP vs OLAP).'
    FROM vals
) t
ORDER BY
    CASE severity WHEN 'high' THEN 1 WHEN 'medium' THEN 2 WHEN 'observe' THEN 3 ELSE 4 END,
    parameter;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

          parameter           |            current_value             | severity |                                      finding                                      |                                       recommendation                                        
------------------------------+--------------------------------------+----------+-----------------------------------------------------------------------------------+---------------------------------------------------------------------------------------------
 shared_buffers               | 160 MB                               | high     | Low shared_buffers can increase physical reads.                                   | For dedicated DB hosts, start around 15-30% of RAM and validate with cache hit and latency.
 max_wal_size                 | 1024 MB                              | medium   | Low max_wal_size can force frequent checkpoints and write pressure.               | Increase max_wal_size and review checkpoint metrics.
 random_page_cost             | 4                                    | medium   | High random_page_cost may discourage useful index scans on SSD/cloud storage.     | Benchmark lower values (for example 1.1-2.0) in staging before production.
 track_io_timing              | off                                  | medium   | Without I/O timing, root-cause analysis of storage bottlenecks is limited.        | Enable track_io_timing for better performance diagnostics.
 work_mem                     | 4096 kB                              | medium   | Low work_mem increases sort/hash spill risk (temp files).                         | Increase carefully per workload; remember it is per operation, per backend.
 autovacuum                   | on                                   | ok       | Autovacuum is required to control bloat and transaction age.                      | Keep autovacuum enabled and tune thresholds/scales by table size and write rate.
 checkpoint_completion_target | 0.9                                  | ok       | Low target can create bursty checkpoint I/O.                                      | Use around 0.7-0.9 for smoother write profile.
 effective_cache_size         | 5120 MB                              | ok       | Too-low effective_cache_size can bias planner away from index plans.              | Set roughly to OS cache + shared_buffers visible to PostgreSQL.
 jit                          | on                                   | ok       | JIT may help CPU-heavy long queries but can hurt very short OLTP queries.         | Evaluate JIT effect by workload class (OLTP vs OLAP).
 max_connections              | 100                                  | ok       | Too many direct connections can reduce throughput and increase context switching. | Use a connection pool; target lower active backend count for OLTP.
 parallel_workers             | max_parallel_workers=8, per_gather=2 | ok       | No parallel workers can slow analytical scans and aggregations.                   | Enable and tune parallel workers for OLAP/reporting workloads.
(11 rows)


SAMPLE_OUTPUT_END */
