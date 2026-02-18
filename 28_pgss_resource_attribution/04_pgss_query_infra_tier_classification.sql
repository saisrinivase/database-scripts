/*
Purpose: Classify queries into infra pressure tiers (CPU/IO/Memory spill) using percentages.
Area: PGSS Resource Attribution
Usage: Requires pg_stat_statements.
*/
WITH q AS (
    SELECT
        s.queryid,
        s.calls,
        s.total_exec_time,
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
        coalesce(s.shared_blk_read_time, 0)
        + coalesce(s.shared_blk_write_time, 0)
        + coalesce(s.local_blk_read_time, 0)
        + coalesce(s.local_blk_write_time, 0)
        + coalesce(s.temp_blk_read_time, 0)
        + coalesce(s.temp_blk_write_time, 0) AS io_time,
        coalesce(s.temp_blks_written, 0) * current_setting('block_size')::bigint AS temp_bytes,
        left(s.query, 280) AS query_snippet
    FROM pg_stat_statements s
),
t AS (
    SELECT
        sum(total_exec_time) AS tot_exec,
        sum(cpu_proxy_time) AS tot_cpu,
        sum(io_time) AS tot_io,
        sum(temp_bytes) AS tot_temp
    FROM q
)
SELECT
    q.queryid,
    q.calls,
    q.total_exec_time,
    round((100.0 * q.total_exec_time / NULLIF(t.tot_exec, 0))::numeric, 2) AS pct_exec,
    round((100.0 * q.cpu_proxy_time / NULLIF(t.tot_cpu, 0))::numeric, 2) AS pct_cpu_proxy,
    round((100.0 * q.io_time / NULLIF(t.tot_io, 0))::numeric, 2) AS pct_io,
    round((100.0 * q.temp_bytes / NULLIF(t.tot_temp, 0))::numeric, 2) AS pct_memory_spill,
    CASE
        WHEN (100.0 * q.temp_bytes / NULLIF(t.tot_temp, 0)) >= 5 THEN 'MEMORY-TIER risk'
        WHEN (100.0 * q.io_time / NULLIF(t.tot_io, 0)) >= 5 THEN 'IO-TIER risk'
        WHEN (100.0 * q.cpu_proxy_time / NULLIF(t.tot_cpu, 0)) >= 5 THEN 'CPU-TIER risk'
        ELSE 'LOW-TIER impact'
    END AS infra_tier,
    q.query_snippet
FROM q
CROSS JOIN t
ORDER BY pct_exec DESC NULLS LAST
LIMIT 400;
