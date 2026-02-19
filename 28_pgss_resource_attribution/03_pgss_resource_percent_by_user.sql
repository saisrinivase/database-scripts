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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  user_name |  total_exec_time   |   cpu_proxy_time   | io_time | temp_bytes_written | temp_pretty | pct_exec | pct_cpu_proxy | pct_io | pct_memory_spill 
-- -----------+--------------------+--------------------+---------+--------------------+-------------+----------+---------------+--------+------------------
--  saiendla  | 21184139.636132687 | 21184139.636132687 |       0 |          204218368 | 195 MB      |    99.90 |         99.90 |        |           100.00
--  postgres  |  20461.00471599986 |  20461.00471599986 |       0 |                  0 | 0 bytes     |     0.10 |          0.10 |        |             0.00
-- (2 rows)
-- 
-- SAMPLE_OUTPUT_END
