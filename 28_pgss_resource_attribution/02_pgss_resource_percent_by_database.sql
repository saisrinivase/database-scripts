/*
PostgreSQL DBA Script: Pg Stat Statements Resource Percent By Database
Purpose: Show resource percentage attribution by database from pg_stat_statements.
Area: PGSS Resource Attribution
Usage: Requires pg_stat_statements. Enable track_io_timing before the observation window for timing-derived columns.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Non-I/O elapsed time is a CPU-candidate proxy, not measured CPU. Temp writes measure spill I/O, not allocated RAM.
*/
WITH settings AS (
    SELECT current_setting('track_io_timing') = 'on' AS io_timing_enabled
),
base AS (
    SELECT
        d.datname AS database_name,
        s.total_exec_time,
        coalesce(s.shared_blk_read_time, 0)
        + coalesce(s.shared_blk_write_time, 0)
        + coalesce(s.local_blk_read_time, 0)
        + coalesce(s.local_blk_write_time, 0)
        + coalesce(s.temp_blk_read_time, 0)
        + coalesce(s.temp_blk_write_time, 0) AS io_time,
        CASE WHEN cfg.io_timing_enabled THEN greatest(
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
        ) END AS non_io_elapsed_proxy_time,
        cfg.io_timing_enabled,
        coalesce(s.temp_blks_written, 0) * current_setting('block_size')::bigint AS temp_bytes_written
    FROM pg_stat_statements s
    JOIN pg_database d ON d.oid = s.dbid
    CROSS JOIN settings cfg
),
agg AS (
    SELECT
        database_name,
        sum(total_exec_time) AS total_exec_time,
        sum(io_time) AS io_time,
        bool_and(io_timing_enabled) AS io_timing_enabled,
        sum(non_io_elapsed_proxy_time) AS non_io_elapsed_proxy_time,
        sum(temp_bytes_written) AS temp_bytes_written
    FROM base
    GROUP BY database_name
),
totals AS (
    SELECT
        sum(total_exec_time) AS all_exec,
        sum(io_time) AS all_io,
        sum(non_io_elapsed_proxy_time) AS all_non_io_proxy,
        sum(temp_bytes_written) AS all_temp
    FROM agg
)
SELECT
    a.database_name,
    a.total_exec_time,
    a.io_timing_enabled,
    a.non_io_elapsed_proxy_time,
    a.io_time,
    a.temp_bytes_written,
    pg_size_pretty(a.temp_bytes_written::bigint) AS temp_pretty,
    round((100.0 * a.total_exec_time / NULLIF(t.all_exec, 0))::numeric, 2) AS pct_exec,
    round((100.0 * a.non_io_elapsed_proxy_time / NULLIF(t.all_non_io_proxy, 0))::numeric, 2) AS pct_non_io_elapsed_proxy,
    CASE WHEN a.io_timing_enabled THEN round((100.0 * a.io_time / NULLIF(t.all_io, 0))::numeric, 2) END AS pct_measured_io_time,
    round((100.0 * a.temp_bytes_written / NULLIF(t.all_temp, 0))::numeric, 2) AS pct_temp_spill
FROM agg a
CROSS JOIN totals t
ORDER BY pct_exec DESC NULLS LAST;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--            database_name           |  total_exec_time   |   cpu_proxy_time   | io_time | temp_bytes_written | temp_pretty | pct_exec | pct_cpu_proxy | pct_io | pct_memory_spill 
-- -----------------------------------+--------------------+--------------------+---------+--------------------+-------------+----------+---------------+--------+------------------
--  pgbench_test                      | 21187845.280380692 | 21187845.280380692 |       0 |          192405504 | 183 MB      |    99.92 |         99.92 |        |            94.22
--  script_validation_20260218_172749 |  9668.777081999895 |  9668.777081999895 |       0 |            6750208 | 6592 kB     |     0.05 |          0.05 |        |             3.31
--  postgres                          |  6974.367387999896 |  6974.367387999896 |       0 |            5062656 | 4944 kB     |     0.03 |          0.03 |        |             2.48
--  template1                         |           0.013168 |           0.013168 |       0 |                  0 | 0 bytes     |     0.00 |          0.00 |        |             0.00
--  appdb                             | 26.254455999999994 | 26.254455999999994 |       0 |                  0 | 0 bytes     |     0.00 |          0.00 |        |             0.00
--  perf_test                         |           0.546833 |           0.546833 |       0 |                  0 | 0 bytes     |     0.00 |          0.00 |        |             0.00
--  hypopg_lab                        |          84.404333 |          84.404333 |       0 |                  0 | 0 bytes     |     0.00 |          0.00 |        |             0.00
-- (7 rows)
-- 
-- SAMPLE_OUTPUT_END
