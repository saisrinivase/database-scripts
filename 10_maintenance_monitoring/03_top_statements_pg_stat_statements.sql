/*
PostgreSQL DBA Script: Top Statements Pg Stat Statements
Purpose: Show the top SQL statements with percentage contribution and CPU/IO/memory/WAL pressure classification.
Area: Maintenance and Monitoring
Usage: Requires pg_stat_statements extension. Use this as a first query-performance triage screen before running deeper CPU, memory/temp-spill, I/O, or WAL-specific scripts.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic. PostgreSQL core does not expose exact historical per-query CPU or memory; CPU and memory below are practical proxies from pg_stat_statements timing, block I/O, temp blocks, and WAL counters.
*/
WITH statement_base AS (
    SELECT
        s.queryid,
        s.calls,
        s.total_exec_time,
        s.mean_exec_time,
        s.rows,
        s.shared_blks_hit,
        s.shared_blks_read,
        s.shared_blks_dirtied,
        s.shared_blks_written,
        s.local_blks_hit,
        s.local_blks_read,
        s.local_blks_dirtied,
        s.local_blks_written,
        s.temp_blks_read,
        s.temp_blks_written,
        coalesce(s.shared_blk_read_time, 0)
            + coalesce(s.shared_blk_write_time, 0)
            + coalesce(s.local_blk_read_time, 0)
            + coalesce(s.local_blk_write_time, 0)
            + coalesce(s.temp_blk_read_time, 0)
            + coalesce(s.temp_blk_write_time, 0) AS io_time_ms,
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
        ) AS cpu_proxy_time_ms,
        (coalesce(s.temp_blks_read, 0) + coalesce(s.temp_blks_written, 0)) * current_setting('block_size')::bigint AS temp_bytes_total,
        coalesce(s.temp_blks_written, 0) * current_setting('block_size')::bigint AS temp_bytes_written,
        (coalesce(s.shared_blks_read, 0) + coalesce(s.local_blks_read, 0)) * current_setting('block_size')::bigint AS read_bytes,
        (coalesce(s.shared_blks_written, 0) + coalesce(s.local_blks_written, 0)) * current_setting('block_size')::bigint AS write_bytes,
        coalesce(s.wal_bytes, 0)::numeric AS wal_bytes,
        regexp_replace(s.query, '\s+', ' ', 'g') AS query_snippet
    FROM pg_stat_statements s
),
totals AS (
    SELECT
        sum(total_exec_time) AS all_exec_ms,
        sum(cpu_proxy_time_ms) AS all_cpu_proxy_ms,
        sum(io_time_ms) AS all_io_ms,
        sum(temp_bytes_total) AS all_temp_bytes,
        sum(read_bytes) AS all_read_bytes,
        sum(write_bytes) AS all_write_bytes,
        sum(wal_bytes) AS all_wal_bytes,
        sum(calls) AS all_calls
    FROM statement_base
),
ranked AS (
    SELECT
        b.*,
        row_number() OVER (ORDER BY b.total_exec_time DESC) AS rank_by_total_time
    FROM statement_base b
)
SELECT
    r.rank_by_total_time,
    r.queryid,
    r.calls,
    round((100.0 * r.calls / NULLIF(t.all_calls, 0))::numeric, 2) AS pct_calls,
    round(r.total_exec_time::numeric, 2) AS total_exec_ms,
    round((100.0 * r.total_exec_time / NULLIF(t.all_exec_ms, 0))::numeric, 2) AS pct_total_exec_time,
    round(r.mean_exec_time::numeric, 2) AS mean_exec_ms,
    r.rows,
    round((r.rows::numeric / NULLIF(r.calls, 0)), 2) AS rows_per_call,
    round(r.cpu_proxy_time_ms::numeric, 2) AS cpu_proxy_ms,
    round((100.0 * r.cpu_proxy_time_ms / NULLIF(t.all_cpu_proxy_ms, 0))::numeric, 2) AS pct_cpu_proxy,
    round(r.io_time_ms::numeric, 2) AS io_time_ms,
    round((100.0 * r.io_time_ms / NULLIF(t.all_io_ms, 0))::numeric, 2) AS pct_io_time,
    pg_size_pretty(r.read_bytes::bigint) AS read_volume,
    round((100.0 * r.read_bytes / NULLIF(t.all_read_bytes, 0))::numeric, 2) AS pct_read_volume,
    pg_size_pretty(r.write_bytes::bigint) AS write_volume,
    round((100.0 * r.write_bytes / NULLIF(t.all_write_bytes, 0))::numeric, 2) AS pct_write_volume,
    pg_size_pretty(r.temp_bytes_total::bigint) AS temp_spill_volume,
    round((100.0 * r.temp_bytes_total / NULLIF(t.all_temp_bytes, 0))::numeric, 2) AS pct_temp_spill,
    pg_size_pretty(r.wal_bytes::bigint) AS wal_volume,
    round((100.0 * r.wal_bytes / NULLIF(t.all_wal_bytes, 0))::numeric, 2) AS pct_wal_volume,
    r.shared_blks_hit,
    r.shared_blks_read,
    r.temp_blks_read,
    r.temp_blks_written,
    CASE
        WHEN r.temp_bytes_total > 0
             AND (
                 r.temp_bytes_total >= 1024::bigint * 1024 * 1024
                 OR r.temp_bytes_total >= greatest(r.read_bytes, r.write_bytes, r.wal_bytes)
             )
            THEN 'MEMORY/TEMP-SPILL intensive'
        WHEN r.io_time_ms > r.cpu_proxy_time_ms
             OR (
                 r.read_bytes > 0
                 AND r.read_bytes >= greatest(r.temp_bytes_total, r.write_bytes, r.wal_bytes)
             )
            THEN 'IO intensive'
        WHEN r.wal_bytes > 0
             AND (
                 r.wal_bytes >= 1024::bigint * 1024 * 1024
                 OR r.wal_bytes >= greatest(r.temp_bytes_total, r.read_bytes, r.write_bytes)
             )
            THEN 'WAL/WRITE intensive'
        WHEN r.cpu_proxy_time_ms >= greatest(r.io_time_ms, 0)
            THEN 'CPU intensive proxy'
        ELSE 'MIXED resource profile'
    END AS dominant_resource_profile,
    CASE
        WHEN r.temp_bytes_total > 0
            THEN 'Check sort/hash spill plans, work_mem scope, row estimates, indexes, and temp file pressure.'
        WHEN r.io_time_ms > r.cpu_proxy_time_ms OR r.read_bytes > 0
            THEN 'Check read-heavy plans, missing indexes, cache hit ratio, pg_stat_io/storage latency, and full scans.'
        WHEN r.wal_bytes > 0 AND (r.shared_blks_dirtied + r.shared_blks_written + r.local_blks_dirtied + r.local_blks_written) > 0
            THEN 'Check write amplification, indexes on write-heavy tables, batch size, checkpoint/WAL pressure, and autovacuum.'
        ELSE 'Check execution plan, joins, functions, expressions, row estimates, and CPU saturation.'
    END AS recommended_next_step,
    'Deep dives: 11_performance_tuning/07_top_10_cpu_intensive_queries_pgadmin.sql; 11_performance_tuning/08_top_10_temp_disk_spill_queries_pgadmin.sql; 11_performance_tuning/09_top_10_memory_pressure_queries_pgadmin.sql; 11_performance_tuning/04_io_bound_query_candidates.sql; 28_pgss_resource_attribution/01_pgss_query_resource_percent.sql' AS followup_scripts,
    r.query_snippet
FROM ranked r
CROSS JOIN totals t
WHERE r.rank_by_total_time <= 10
ORDER BY r.rank_by_total_time;




-- SAMPLE_OUTPUT_BEGIN
--  rank_by_total_time | queryid | calls | pct_calls | total_exec_ms | pct_total_exec_time | pct_cpu_proxy | pct_io_time | read_volume | pct_read_volume | temp_spill_volume | pct_temp_spill | wal_volume | pct_wal_volume | dominant_resource_profile   | recommended_next_step
-- --------------------+---------+-------+-----------+---------------+---------------------+---------------+-------------+-------------+-----------------+-------------------+----------------+------------+----------------+-----------------------------+------------------------------
--                   1 | 12345   | 10000 |     12.50 |     250000.00 |               40.25 |         42.10 |        2.00 | 10 MB       |            0.20 | 0 bytes           |           0.00 | 0 bytes    |           0.00 | CPU intensive proxy         | Check execution plan...
--                   2 | 45678   |   250 |      0.31 |      90000.00 |               14.49 |          8.00 |       51.25 | 80 GB       |           65.00 | 0 bytes           |           0.00 | 0 bytes    |           0.00 | IO intensive                | Check read-heavy plans...
--                   3 | 98765   |    12 |      0.01 |      45000.00 |                7.25 |          4.00 |        3.00 | 500 MB      |            1.00 | 30 GB             |          88.00 | 0 bytes    |           0.00 | MEMORY/TEMP-SPILL intensive | Check sort/hash spill...
-- (10 rows)
-- SAMPLE_OUTPUT_END

-- HISTORICAL_SAMPLE_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--        queryid        |  calls  |  total_exec_time   |     mean_exec_time     |  rows   | shared_blks_hit | shared_blks_read | temp_blks_written |                                                                         query_snippet                                                                          
-- ----------------------+---------+--------------------+------------------------+---------+-----------------+------------------+-------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------
--   1144016440436625022 | 5332823 | 20318063.253471453 |     3.8100014295381928 | 5332823 |        45639018 |         10664795 |                 0 | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
--  -5371882943115234533 | 5332823 |  440938.2827256841 |    0.08268383982104996 | 5332823 |        30081894 |             1205 |                 0 | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
--   -305747636952590102 | 5332823 | 209356.47065673055 |   0.039258094757131864 | 5332823 |        27087536 |             1533 |                 0 | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
--   3387776431457662738 | 5332823 | 107882.85510483896 |   0.020229971087544072 | 5332823 |         5534382 |            19313 |                 0 | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
--  -1078345578982625442 | 5332823 |  36480.01148695377 |   0.006840656719152106 | 5332823 |        29324806 |               55 |                 0 | SELECT abalance FROM pgbench_accounts WHERE aid = $1
--   3481893718825960883 |    7109 |  20055.74470699987 |     2.8211766362357635 |   35545 |          216589 |               97 |                 0 | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                              +
--                       |         |                    |                        |         |                 |                  |                   | FROM (SELECT                                                                                                                                                  +
--                       |         |                    |                        |         |                 |                  |                   |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                 +
--                       |         |                    |                        |         |                 |                  |                   |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = $3 AND datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $4))  AS "Active",+
--                       |         |                    |                        |         |                 |                  |                   |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE state = $5 AND datname = (SELECT datname FROM pg_catalog.pg_da
--  -6652883949691502391 |       4 |        4649.534541 |          1162.38363525 | 1000000 |         8620939 |                4 |              1712 | INSERT INTO migration_v2_lab.child_events (account_id, event_type, amount)                                                                                    +
--                       |         |                    |                        |         |                 |                  |                   | SELECT                                                                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   |     ($1 + (random() * $2)::int)::bigint,                                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   |     CASE WHEN gs % $3 = $4 THEN $5 WHEN gs % $6 = $7 THEN $8 ELSE $9 END,                                                                                     +
--                       |         |                    |                        |         |                 |                  |                   |     round((random() * $10)::numeric, $11)                                                                                                                     +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($12, $13) AS gs
--  -8275299279783089467 |       4 |         4633.07625 |           1158.2690625 |       0 |           14272 |                9 |              6426 | CREATE INDEX IF NOT EXISTS idx_v2_order_fact_search_lower                                                                                                     +
--                       |         |                    |                        |         |                 |                  |                   |     ON migration_v2_lab.order_fact (lower(search_text))
--    847396262454713343 |       4 |        3489.204166 |            872.3010415 | 1200000 |         4234736 |                4 |              2052 | INSERT INTO migration_v2_lab.order_fact (account_id, filter_key, search_text, order_amount)                                                                   +
--                       |         |                    |                        |         |                 |                  |                   | SELECT                                                                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   |     ($1 + (random() * $2)::int)::bigint,                                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   |     ($3 + (random() * $4)::int),                                                                                                                              +
--                       |         |                    |                        |         |                 |                  |                   |     CASE WHEN gs % $5 = $6 THEN $7 || gs ELSE $8 || gs END,                                                                                                   +
--                       |         |                    |                        |         |                 |                  |                   |     round(($9 + random() * $10)::numeric, $11)                                                                                                                +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($12, $13) AS gs
--  -3869797102397106429 |       4 |        3082.171834 |            770.5429585 |  360000 |         1451244 |                4 |                 0 | INSERT INTO migration_v2_lab.bloat_pressure_table (payload)                                                                                                   +
--                       |         |                    |                        |         |                 |                  |                   | SELECT repeat(md5(gs::text), $1)                                                                                                                              +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($2, $3) AS gs
--  -5065162101678021495 |       5 |         2684.81971 |             536.963942 |  780000 |         3021548 |                5 |              1232 | INSERT INTO migration_v2_lab.stale_stats_table (payload)                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   | SELECT md5(random()::text) || md5((random() * $1)::text)                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($2, $3)
--   7127220720807722591 |       4 |         2175.87979 |            543.9699475 |  480000 |         4326932 |                4 |               824 | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)                                                                                          +
--                       |         |                    |                        |         |                 |                  |                   | SELECT                                                                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   |     ($1 + (random() * $2)::int)::bigint,                                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   |     round((random() * $3)::numeric, $4)                                                                                                                       +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($5, $6)
--   2285531965341755341 |       4 |        1982.815083 |           495.70377075 |  480000 |         3259947 |              729 |                 0 | UPDATE migration_v2_lab.amount_mapping_risk                                                                                                                   +
--                       |         |                    |                        |         |                 |                  |                   | SET                                                                                                                                                           +
--                       |         |                    |                        |         |                 |                  |                   |     target_int4_model = CASE                                                                                                                                  +
--                       |         |                    |                        |         |                 |                  |                   |         WHEN abs(source_numeric) <= $1 THEN source_numeric::int                                                                                               +
--                       |         |                    |                        |         |                 |                  |                   |         ELSE target_int4_model                                                                                                                                +
--                       |         |                    |                        |         |                 |                  |                   |     END,                                                                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   |     target_bigint_model = source_numeric::bigint                                                                                                              +
--                       |         |                    |                        |         |                 |                  |                   | WHERE target_bigint_model IS NULL                                                                                                                             +
--                       |         |                    |                        |         |                 |                  |                   |   AND abs(source_numeric) <= $2
--   1459853053728673055 |       8 |        1851.923791 |     231.49047387500002 |       0 |           27943 |                4 |                 0 | ANALYZE migration_v2_lab.order_fact
--    215870004070435986 |       8 | 1781.2664600000003 |            222.6583075 |       0 |           16559 |               15 |                 0 | ANALYZE migration_v2_lab.partitioned_events
--    450201137788272562 |       1 |        1674.504167 |            1674.504167 |       0 |            9664 |            29989 |                 0 | ANALYZE
--   7127220720807722591 |       3 |        1636.255042 |      545.4183473333334 |  360000 |         3245196 |                3 |               618 | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)                                                                                          +
--                       |         |                    |                        |         |                 |                  |                   | SELECT                                                                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   |     ($1 + (random() * $2)::int)::bigint,                                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   |     round((random() * $3)::numeric, $4)                                                                                                                       +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($5, $6)
--  -1479418139676470911 |       4 |        1535.621918 |            383.9054795 |       0 |            4409 |                0 |                 0 | CREATE INDEX idx_v2_sales_ref_b ON migration_v2_lab.sales_catalog (item_ref)
--   4361856503355632769 |       4 | 1521.6664580000001 |     380.41661450000004 |       0 |            4394 |                0 |                 0 | CREATE INDEX idx_v2_sales_ref_a ON migration_v2_lab.sales_catalog (item_ref)
--   4667898782383165389 |       4 |        1190.093041 |           297.52326025 |  480000 |         1927764 |                4 |               824 | INSERT INTO migration_v2_lab.sales_catalog (item_ref, item_type, price)                                                                                       +
--                       |         |                    |                        |         |                 |                  |                   | SELECT                                                                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   |     $1 || gs,                                                                                                                                                 +
--                       |         |                    |                        |         |                 |                  |                   |     CASE WHEN gs % $2 = $3 THEN $4 WHEN gs % $5 = $6 THEN $7 WHEN gs % $8 = $9 THEN $10 WHEN gs % $11 = $12 THEN $13 ELSE $14 END,                            +
--                       |         |                    |                        |         |                 |                  |                   |     round(($15 + random() * $16)::numeric, $17)                                                                                                               +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($18, $19) AS gs
--   3689806360888379158 | 1120000 | 1123.6539700004319 |   0.001003262473214298 | 1120000 |         4480060 |                0 |                 0 | SELECT $2 FROM ONLY "migration_v2_lab"."parent_accounts" x WHERE "account_id" OPERATOR(pg_catalog.=) $1 FOR KEY SHARE OF x
--  -4598960938853719316 |       4 |          1100.3515 |     275.08787499999994 |  100000 |          402368 |                4 |                 0 | INSERT INTO migration_v1_lab.dml_bloat_table (payload)                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   | SELECT repeat(md5(gs::text), $1)                                                                                                                              +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($2, $3) AS gs
--  -5938169015537755073 |       4 |        1016.337374 |     254.08434350000002 |  400000 |         1606905 |                8 |                 0 | INSERT INTO migration_v2_lab.partitioned_events (event_date, event_payload)                                                                                   +
--                       |         |                    |                        |         |                 |                  |                   | SELECT                                                                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   |     date $1 + (gs % $2),                                                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   |     md5(gs::text)                                                                                                                                             +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($3, $4) AS gs
--  -2522370506372832129 |       8 |         935.383875 |          116.922984375 |       0 |            7009 |              745 |                 0 | ANALYZE migration_v2_lab.customer_contact_compat
--   1579180460630060410 |       4 |  903.8009159999999 |             225.950229 |  480000 |         1926084 |                4 |               824 | INSERT INTO migration_v2_lab.amount_mapping_risk (source_numeric, target_int4_model)                                                                          +
--                       |         |                    |                        |         |                 |                  |                   | SELECT                                                                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   |     CASE                                                                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   |         WHEN gs % $1 = $2 THEN $3 + gs                                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   |         WHEN gs % $4 = $5 THEN $6 - gs                                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   |         ELSE gs::numeric                                                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   |     END,                                                                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   |     $7                                                                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($8, $9) AS gs
--  -4598960938853719316 |       3 |          835.59025 |      278.5300833333333 |   75000 |          301776 |                3 |                 0 | INSERT INTO migration_v1_lab.dml_bloat_table (payload)                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   | SELECT repeat(md5(gs::text), $1)                                                                                                                              +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($2, $3) AS gs
--  -5398677000037045473 |       1 |         802.498625 |             802.498625 |       0 |             238 |            53105 |                 0 | CREATE DATABASE script_validation_20260218_172749 TEMPLATE perf_test
--  -7376821209867977575 |       8 |         791.101833 |      98.88772912499999 |       0 |            8783 |                1 |                 0 | ANALYZE migration_v2_lab.sales_catalog
--  -5065162101678021495 |       4 |         786.323249 |           196.58081225 |  240000 |          965520 |                4 |                 0 | INSERT INTO migration_v1_lab.stale_stats_table (payload)                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   | SELECT md5(random()::text) || md5((random() * $1)::text)                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($2, $3)
--   1330686554379899739 |       4 |  740.5437929999999 |     185.13594824999998 |  360000 |         1445356 |                4 |                 0 | INSERT INTO migration_v2_lab.customer_contact_compat (email, phone, comments)                                                                                 +
--                       |         |                    |                        |         |                 |                  |                   | SELECT                                                                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   |     CASE WHEN gs % $1 = $2 THEN $3 ELSE $4 || gs || $5 END,                                                                                                   +
--                       |         |                    |                        |         |                 |                  |                   |     CASE WHEN gs % $6 = $7 THEN $8 ELSE $9 || lpad((gs % $10)::text, $11, $12) END,                                                                           +
--                       |         |                    |                        |         |                 |                  |                   |     CASE WHEN gs % $13 = $14 THEN $15 ELSE $16 END                                                                                                            +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($17, $18) AS gs
--   3911214664636020243 |       4 |         728.565874 |     182.14146849999997 |  205716 |         1308970 |              734 |                 0 | UPDATE migration_v2_lab.customer_contact_compat                                                                                                               +
--                       |         |                    |                        |         |                 |                  |                   | SET                                                                                                                                                           +
--                       |         |                    |                        |         |                 |                  |                   |     email = NULLIF(email, $1),                                                                                                                                +
--                       |         |                    |                        |         |                 |                  |                   |     phone = NULLIF(phone, $2),                                                                                                                                +
--                       |         |                    |                        |         |                 |                  |                   |     comments = NULLIF(comments, $3)                                                                                                                           +
--                       |         |                    |                        |         |                 |                  |                   | WHERE email = $4 OR phone = $5 OR comments = $6
--   1021157187189676460 |       8 |  674.5953319999999 |             84.3244165 |       0 |            4167 |              466 |                 0 | ANALYZE migration_v2_lab.customer_staging_no_pk
--  -4122962008160556687 |       6 |         662.406499 |     110.40108316666667 |       0 |            5753 |                2 |                 0 | ANALYZE migration_v1_lab.stale_stats_table
--   7127220720807722591 |       1 |         618.777208 |             618.777208 |  120000 |         1081733 |                1 |               206 | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)                                                                                          +
--                       |         |                    |                        |         |                 |                  |                   | SELECT                                                                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   |     ($1 + (random() * $2)::int)::bigint,                                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   |     round((random() * $3)::numeric, $4)                                                                                                                       +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($5, $6)
--  -1900060566350483813 |       8 |  615.3488340000001 |            76.91860425 |       0 |            2581 |              851 |                 0 | ANALYZE migration_v2_lab.parent_accounts
--   6097083398544187049 | 5332823 |  610.4023310318215 | 0.00011446138958671586 |       0 |               0 |                0 |                 0 | END
--   4854991825702068830 | 5332823 |   599.397160031148 | 0.00011239772255708013 |       0 |               0 |                0 |                 0 | BEGIN
--  -5065162101678021495 |       3 |         549.837125 |     183.27904166666667 |  180000 |          724140 |                3 |                 0 | INSERT INTO migration_v1_lab.stale_stats_table (payload)                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   | SELECT md5(random()::text) || md5((random() * $1)::text)                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($2, $3)
--  -6785520009338350043 |       4 |            508.534 |               127.1335 |       0 |            2232 |                0 |                 0 | CREATE INDEX idx_product_sku_a ON migration_v1_lab.product_catalog (sku)
--   5250747760378150803 |       4 |         506.309959 |     126.57748975000001 |       0 |            2077 |                0 |                 0 | CREATE INDEX idx_product_sku_b ON migration_v1_lab.product_catalog (sku)
--    921579968067292190 |       4 |         475.228082 |     118.80702050000001 |       0 |            7365 |             4093 |                 0 | ANALYZE migration_v2_lab.stale_stats_table
--  -2954928409753106123 |       4 |         452.848375 |           113.21209375 |  200000 |          802336 |                4 |                 0 | INSERT INTO migration_v1_lab.product_catalog (sku, category, price)                                                                                           +
--                       |         |                    |                        |         |                 |                  |                   | SELECT                                                                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   |     $1 || gs,                                                                                                                                                 +
--                       |         |                    |                        |         |                 |                  |                   |     CASE                                                                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   |         WHEN gs % $2 = $3 THEN $4                                                                                                                             +
--                       |         |                    |                        |         |                 |                  |                   |         WHEN gs % $5 = $6 THEN $7                                                                                                                             +
--                       |         |                    |                        |         |                 |                  |                   |         WHEN gs % $8 = $9 THEN $10                                                                                                                            +
--                       |         |                    |                        |         |                 |                  |                   |         WHEN gs % $11 = $12 THEN $13                                                                                                                          +
--                       |         |                    |                        |         |                 |                  |                   |         ELSE $14                                                                                                                                              +
--                       |         |                    |                        |         |                 |                  |                   |     END,                                                                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   |     round(($15 + random() * $16)::numeric, $17)                                                                                                               +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($18, $19) AS gs
--  -6785520009338350043 |       3 |         379.612709 |     126.53756966666666 |       0 |            1671 |                0 |                 0 | CREATE INDEX idx_product_sku_a ON migration_v1_lab.product_catalog (sku)
--   5250747760378150803 |       3 |         375.667333 |     125.22244433333333 |       0 |            1554 |                0 |                 0 | CREATE INDEX idx_product_sku_b ON migration_v1_lab.product_catalog (sku)
--   3689806360888379158 |  480000 |  374.3436859998984 |  0.0007798826791666557 |  480000 |         1920048 |                0 |                 0 | SELECT $2 FROM ONLY "migration_v1_lab"."parent_accounts" x WHERE "account_id" OPERATOR(pg_catalog.=) $1 FOR KEY SHARE OF x
--   8808525780625751662 |       4 | 345.25991700000003 |            86.31497925 |       0 |            2027 |                0 |                 0 | ANALYZE migration_v1_lab.product_catalog
--  -4122962008160556687 |       3 |         343.253458 |     114.41781933333333 |       0 |            2899 |                3 |                 0 | ANALYZE migration_v1_lab.stale_stats_table
--   9120805628915790401 |       5 |         327.954707 |             65.5909414 |  210000 |          631653 |                5 |                 0 | INSERT INTO migration_v2_lab.parent_accounts (account_id, account_name)                                                                                       +
--                       |         |                    |                        |         |                 |                  |                   | SELECT gs, $1 || gs                                                                                                                                           +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($2, $3) AS gs
--  -2954928409753106123 |       3 |         324.343707 |             108.114569 |  150000 |          601752 |                3 |                 0 | INSERT INTO migration_v1_lab.product_catalog (sku, category, price)                                                                                           +
--                       |         |                    |                        |         |                 |                  |                   | SELECT                                                                                                                                                        +
--                       |         |                    |                        |         |                 |                  |                   |     $1 || gs,                                                                                                                                                 +
--                       |         |                    |                        |         |                 |                  |                   |     CASE                                                                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   |         WHEN gs % $2 = $3 THEN $4                                                                                                                             +
--                       |         |                    |                        |         |                 |                  |                   |         WHEN gs % $5 = $6 THEN $7                                                                                                                             +
--                       |         |                    |                        |         |                 |                  |                   |         WHEN gs % $8 = $9 THEN $10                                                                                                                            +
--                       |         |                    |                        |         |                 |                  |                   |         WHEN gs % $11 = $12 THEN $13                                                                                                                          +
--                       |         |                    |                        |         |                 |                  |                   |         ELSE $14                                                                                                                                              +
--                       |         |                    |                        |         |                 |                  |                   |     END,                                                                                                                                                      +
--                       |         |                    |                        |         |                 |                  |                   |     round(($15 + random() * $16)::numeric, $17)                                                                                                               +
--                       |         |                    |                        |         |                 |                  |                   | FROM generate_series($18, $19) AS gs
--   3689806360888379158 |  360000 |  297.5106209998934 |  0.0008264183916666604 |  360000 |         1440036 |                0 |                 0 | SELECT $2 FROM ONLY "migration_v1_lab"."parent_accounts" x WHERE "account_id" OPERATOR(pg_catalog.=) $1 FOR KEY SHARE OF x
-- (50 rows)
-- 
-- HISTORICAL_SAMPLE_END
