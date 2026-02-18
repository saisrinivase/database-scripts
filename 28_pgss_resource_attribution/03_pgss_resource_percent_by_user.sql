/*
Purpose: Show resource percentage attribution by login role from pg_stat_statements.
Area: PGSS Resource Attribution
Usage: Requires pg_stat_statements.
*/
WITH base AS (
    SELECT
        r.rolname AS user_name,
        s.total_exec_time,
        coalesce(s.shared_blk_read_time, 0)
        + coalesce(s.shared_blk_write_time, 0)
        + coalesce(s.local_blk_read_time, 0)
        + coalesce(s.local_blk_write_time, 0)
        + coalesce(s.temp_blk_read_time, 0)
        + coalesce(s.temp_blk_write_time, 0) AS io_time,
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
        coalesce(s.temp_blks_written, 0) * current_setting('block_size')::bigint AS temp_bytes_written
    FROM pg_stat_statements s
    JOIN pg_roles r
        ON r.oid = s.userid
),
agg AS (
    SELECT
        user_name,
        sum(total_exec_time) AS total_exec_time,
        sum(io_time) AS io_time,
        sum(cpu_proxy_time) AS cpu_proxy_time,
        sum(temp_bytes_written) AS temp_bytes_written
    FROM base
    GROUP BY user_name
),
totals AS (
    SELECT
        sum(total_exec_time) AS all_exec,
        sum(io_time) AS all_io,
        sum(cpu_proxy_time) AS all_cpu,
        sum(temp_bytes_written) AS all_temp
    FROM agg
)
SELECT
    a.user_name,
    a.total_exec_time,
    a.cpu_proxy_time,
    a.io_time,
    a.temp_bytes_written,
    pg_size_pretty(a.temp_bytes_written::bigint) AS temp_pretty,
    round((100.0 * a.total_exec_time / NULLIF(t.all_exec, 0))::numeric, 2) AS pct_exec,
    round((100.0 * a.cpu_proxy_time / NULLIF(t.all_cpu, 0))::numeric, 2) AS pct_cpu_proxy,
    round((100.0 * a.io_time / NULLIF(t.all_io, 0))::numeric, 2) AS pct_io,
    round((100.0 * a.temp_bytes_written / NULLIF(t.all_temp, 0))::numeric, 2) AS pct_memory_spill
FROM agg a
CROSS JOIN totals t
ORDER BY pct_exec DESC NULLS LAST;
