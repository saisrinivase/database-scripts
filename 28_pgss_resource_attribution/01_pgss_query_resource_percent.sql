/*
PostgreSQL DBA Script: Pg Stat Statements Query Resource Percent
Purpose: Attribute query elapsed time, measured I/O time, and temp-file spill percentages from pg_stat_statements.
Area: PGSS Resource Attribution
Usage: Requires pg_stat_statements. Enable track_io_timing before the observation window for timing-derived columns.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Non-I/O elapsed time is only a CPU-candidate proxy, not measured CPU. Temp writes measure spill I/O, not allocated RAM.
*/

SELECT
    stats_reset AS pgss_stats_reset,
    clock_timestamp() - stats_reset AS statistics_age,
    'All following counters are cumulative since pgss_stats_reset; use snapshots for an incident interval.' AS measurement_boundary
FROM pg_stat_statements_info;

WITH settings AS (
    SELECT current_setting('track_io_timing') = 'on' AS io_timing_enabled
),
base AS (
    SELECT
        s.queryid,
        s.calls,
        s.total_exec_time,
        s.mean_exec_time,
        coalesce((to_jsonb(s)->>'shared_blk_read_time')::numeric, (to_jsonb(s)->>'blk_read_time')::numeric, 0)
        + coalesce((to_jsonb(s)->>'shared_blk_write_time')::numeric, (to_jsonb(s)->>'blk_write_time')::numeric, 0)
        + coalesce((to_jsonb(s)->>'local_blk_read_time')::numeric, 0)
        + coalesce((to_jsonb(s)->>'local_blk_write_time')::numeric, 0)
        + coalesce((to_jsonb(s)->>'temp_blk_read_time')::numeric, 0)
        + coalesce((to_jsonb(s)->>'temp_blk_write_time')::numeric, 0) AS io_time,
        coalesce(s.temp_blks_written, 0) * current_setting('block_size')::bigint AS temp_bytes_written,
        CASE WHEN cfg.io_timing_enabled THEN greatest(
            s.total_exec_time
            - (
                coalesce((to_jsonb(s)->>'shared_blk_read_time')::numeric, (to_jsonb(s)->>'blk_read_time')::numeric, 0)
                + coalesce((to_jsonb(s)->>'shared_blk_write_time')::numeric, (to_jsonb(s)->>'blk_write_time')::numeric, 0)
                + coalesce((to_jsonb(s)->>'local_blk_read_time')::numeric, 0)
                + coalesce((to_jsonb(s)->>'local_blk_write_time')::numeric, 0)
                + coalesce((to_jsonb(s)->>'temp_blk_read_time')::numeric, 0)
                + coalesce((to_jsonb(s)->>'temp_blk_write_time')::numeric, 0)
            ),
            0
        ) END AS non_io_elapsed_proxy_time,
        cfg.io_timing_enabled,
        s.query AS query_snippet
    FROM pg_stat_statements s
    CROSS JOIN settings cfg
),
totals AS (
    SELECT
        sum(total_exec_time) AS total_exec_time_all,
        sum(io_time) AS total_io_time_all,
        sum(non_io_elapsed_proxy_time) AS total_non_io_proxy_time_all,
        sum(temp_bytes_written) AS total_temp_bytes_all
    FROM base
)
SELECT
    b.queryid,
    b.calls,
    b.total_exec_time,
    b.mean_exec_time,
    b.io_timing_enabled,
    b.non_io_elapsed_proxy_time,
    b.io_time,
    b.temp_bytes_written,
    pg_size_pretty(b.temp_bytes_written::bigint) AS temp_pretty,
    round((100.0 * b.total_exec_time / NULLIF(t.total_exec_time_all, 0))::numeric, 2) AS pct_total_exec_time,
    round((100.0 * b.non_io_elapsed_proxy_time / NULLIF(t.total_non_io_proxy_time_all, 0))::numeric, 2) AS pct_non_io_elapsed_proxy,
    CASE WHEN b.io_timing_enabled THEN round((100.0 * b.io_time / NULLIF(t.total_io_time_all, 0))::numeric, 2) END AS pct_measured_io_time,
    round((100.0 * b.temp_bytes_written / NULLIF(t.total_temp_bytes_all, 0))::numeric, 2) AS pct_temp_spill,
    CASE
        WHEN b.temp_bytes_written >= 1024::bigint * 1024 * 1024 THEN 'Temp spill heavy'
        WHEN NOT b.io_timing_enabled THEN 'Timing split unavailable; enable track_io_timing'
        WHEN b.io_time > b.non_io_elapsed_proxy_time THEN 'Measured IO-time heavy'
        WHEN b.non_io_elapsed_proxy_time >= b.io_time THEN 'Non-IO elapsed-time candidate'
        ELSE 'Mixed signals'
    END AS dominant_resource_proxy,
    b.query_snippet
FROM base b
CROSS JOIN totals t
ORDER BY pct_total_exec_time DESC NULLS LAST
LIMIT 300;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--        queryid        |  calls  |   total_exec_time    |     mean_exec_time     |    cpu_proxy_time    | io_time | temp_bytes_written | temp_pretty | pct_total_exec_time | pct_cpu_proxy_time | pct_io_time | pct_memory_spill | dominant_resource_proxy |                                                                                                                                      query_snippet                                                                                                                                       
-- ----------------------+---------+----------------------+------------------------+----------------------+---------+--------------------+-------------+---------------------+--------------------+-------------+------------------+-------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   1144016440436625022 | 5332823 |   20318063.253471453 |     3.8100014295381928 |   20318063.253471453 |       0 |                  0 | 0 bytes     |               95.82 |              95.82 |             |             0.00 | CPU heavy               | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
--  -5371882943115234533 | 5332823 |    440938.2827256841 |    0.08268383982104996 |    440938.2827256841 |       0 |                  0 | 0 bytes     |                2.08 |               2.08 |             |             0.00 | CPU heavy               | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
--   -305747636952590102 | 5332823 |   209356.47065673055 |   0.039258094757131864 |   209356.47065673055 |       0 |                  0 | 0 bytes     |                0.99 |               0.99 |             |             0.00 | CPU heavy               | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
--   3387776431457662738 | 5332823 |   107882.85510483896 |   0.020229971087544072 |   107882.85510483896 |       0 |                  0 | 0 bytes     |                0.51 |               0.51 |             |             0.00 | CPU heavy               | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
--  -1078345578982625442 | 5332823 |    36480.01148695377 |   0.006840656719152106 |    36480.01148695377 |       0 |                  0 | 0 bytes     |                0.17 |               0.17 |             |             0.00 | CPU heavy               | SELECT abalance FROM pgbench_accounts WHERE aid = $1
--   3481893718825960883 |    7109 |    20055.74470699987 |     2.8211766362357635 |    20055.74470699987 |       0 |                  0 | 0 bytes     |                0.09 |               0.09 |             |             0.00 | CPU heavy               | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                                                                                        +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         | FROM (SELECT                                                                                                                                                                                                                                                                            +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                                                                                                                                           +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE s
--  -8275299279783089467 |       5 |          5755.935291 |           1151.1870582 |          5755.935291 |       0 |           65806336 | 63 MB       |                0.03 |               0.03 |             |            32.22 | CPU heavy               | CREATE INDEX IF NOT EXISTS idx_v2_order_fact_search_lower                                                                                                                                                                                                                               +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     ON migration_v2_lab.order_fact (lower(search_text))
--  -6652883949691502391 |       5 |          5811.473333 |           1162.2946666 |          5811.473333 |       0 |           17530880 | 17 MB       |                0.03 |               0.03 |             |             8.58 | CPU heavy               | INSERT INTO migration_v2_lab.child_events (account_id, event_type, amount)                                                                                                                                                                                                              +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         | SELECT                                                                                                                                                                                                                                                                                  +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     ($1 + (random() * $2)::int)::bigint,                                                                                                                                                                                                                                                +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     CASE WHEN gs % $3 = $4 THEN $5 WHEN gs % $6 = $7 THEN $8 ELSE $9 END,                                                                                                                                                                                                               +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     round((random() * $10)::numeric, $11)                                                                                                                                                                                                                                               +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         | FROM generate_series($12, $13) AS gs
--  -3869797102397106429 |       5 |   3871.3378340000004 |            774.2675668 |   3871.3378340000004 |       0 |                  0 | 0 bytes     |                0.02 |               0.02 |             |             0.00 | CPU heavy               | INSERT INTO migration_v2_lab.bloat_pressure_table (payload)                                                                                                                                                                                                                             +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         | SELECT repeat(md5(gs::text), $1)                                                                                                                                                                                                                                                        +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         | FROM generate_series($2, $3) AS gs
--    847396262454713343 |       5 |          4373.427291 |            874.6854582 |          4373.427291 |       0 |           21012480 | 20 MB       |                0.02 |               0.02 |             |            10.29 | CPU heavy               | INSERT INTO migration_v2_lab.order_fact (account_id, filter_key, search_text, order_amount)                                                                                                                                                                                             +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         | SELECT                                                                                                                                                                                                                                                                                  +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     ($1 + (random() * $2)::int)::bigint,                                                                                                                                                                                                                                                +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     ($3 + (random() * $4)::int),                                                                                                                                                                                                                                                        +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     CASE WHEN gs % $5 = $6 THEN $7 || gs ELSE $8 || gs END,                                                                                                                                                                                                                             +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     round(($9 + random() * $10)::numeric, $11)                                                                                                                                                                                                                                          +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         | 
--  -5065162101678021495 |       7 |          3505.868209 |     500.83831557142855 |          3505.868209 |       0 |           12615680 | 12 MB       |                0.02 |               0.02 |             |             6.18 | CPU heavy               | INSERT INTO migration_v2_lab.stale_stats_table (payload)                                                                                                                                                                                                                                +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         | SELECT md5(random()::text) || md5((random() * $1)::text)                                                                                                                                                                                                                                +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         | FROM generate_series($2, $3)
--   2285531965341755341 |       5 |           2260.70925 |              452.14185 |           2260.70925 |       0 |                  0 | 0 bytes     |                0.01 |               0.01 |             |             0.00 | CPU heavy               | UPDATE migration_v2_lab.amount_mapping_risk                                                                                                                                                                                                                                             +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         | SET                                                                                                                                                                                                                                                                                     +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     target_int4_model = CASE                                                                                                                                                                                                                                                            +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |         WHEN abs(source_numeric) <= $1 THEN source_numeric::int                                                                                                                                                                                                                         +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |         ELSE target_int4_model                                                                                                                                                                                                                                                          +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     END,                                                                                                                                                                                                                                                                                +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |     target_bigint_model = source_numeric::bigint                                                                                                                                                                                                                                        +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         | WHERE target_bigint_model IS NULL                                                                                                                                                                                                                                                       +
--                       |         |                      |                        |                      |         |                    |             |                     |                    |             |                  |                         |   AND abs(source
--   4361856503355632769 |       5 |   1909.8560410000002 |     381.97120820000004 |   1909.8560410000002 |       0 |                  0 | 0 bytes     |                0.01 |               0.01 |             |             0.00 | CPU heavy               | CREATE INDEX idx_v2_sales_ref_a ON migration_v2_lab.sales_catalog (item_ref)
-- ... remaining sample rows omitted; run the script for current environment-specific results.
-- SAMPLE_OUTPUT_END
