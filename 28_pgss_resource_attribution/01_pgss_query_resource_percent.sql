/*
Purpose: Attribute query resource usage using pg_stat_statements with CPU/IO/memory-spill percentages.
Area: PGSS Resource Attribution
Usage: Requires pg_stat_statements and track_io_timing for better IO-to-CPU split.
Note: CPU is a proxy: total_exec_time minus shared/local/temp block read/write time.
*/
WITH base AS (
    SELECT
        s.queryid,
        s.calls,
        s.total_exec_time,
        s.mean_exec_time,
        coalesce(s.shared_blk_read_time, 0)
        + coalesce(s.shared_blk_write_time, 0)
        + coalesce(s.local_blk_read_time, 0)
        + coalesce(s.local_blk_write_time, 0)
        + coalesce(s.temp_blk_read_time, 0)
        + coalesce(s.temp_blk_write_time, 0) AS io_time,
        coalesce(s.temp_blks_written, 0) * current_setting('block_size')::bigint AS temp_bytes_written,
        greatest(
            s.total_exec_time
            - (
                coalesce(s.shared_blk_read_time, 0)
                + coalesce(s.shared_blk_write_time, 0)
                + coalesce(s.local_blk_read_time, 0)
                + coalesce(s.local_blk_write_time, 0)
                + coalesce(s.temp_blk_read_time, 0)
                + coalesce(s.temp_blk_write_time, 0)
            ),
            0
        ) AS cpu_proxy_time,
        left(s.query, 280) AS query_snippet
    FROM pg_stat_statements s
),
totals AS (
    SELECT
        sum(total_exec_time) AS total_exec_time_all,
        sum(io_time) AS total_io_time_all,
        sum(cpu_proxy_time) AS total_cpu_proxy_time_all,
        sum(temp_bytes_written) AS total_temp_bytes_all
    FROM base
)
SELECT
    b.queryid,
    b.calls,
    b.total_exec_time,
    b.mean_exec_time,
    b.cpu_proxy_time,
    b.io_time,
    b.temp_bytes_written,
    pg_size_pretty(b.temp_bytes_written::bigint) AS temp_pretty,
    round((100.0 * b.total_exec_time / NULLIF(t.total_exec_time_all, 0))::numeric, 2) AS pct_total_exec_time,
    round((100.0 * b.cpu_proxy_time / NULLIF(t.total_cpu_proxy_time_all, 0))::numeric, 2) AS pct_cpu_proxy_time,
    round((100.0 * b.io_time / NULLIF(t.total_io_time_all, 0))::numeric, 2) AS pct_io_time,
    round((100.0 * b.temp_bytes_written / NULLIF(t.total_temp_bytes_all, 0))::numeric, 2) AS pct_memory_spill,
    CASE
        WHEN b.temp_bytes_written > 0 AND b.temp_bytes_written >= 1024::bigint * 1024 * 1024 THEN 'Memory spill heavy'
        WHEN b.io_time > b.cpu_proxy_time THEN 'IO heavy'
        WHEN b.cpu_proxy_time >= b.io_time THEN 'CPU heavy'
        ELSE 'Mixed'
    END AS dominant_resource_proxy,
    b.query_snippet
FROM base b
CROSS JOIN totals t
ORDER BY pct_total_exec_time DESC NULLS LAST
LIMIT 300;
