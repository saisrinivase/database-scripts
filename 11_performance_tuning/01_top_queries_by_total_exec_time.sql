/*
PostgreSQL DBA Script: Top Queries By Total Exec Time
Purpose: Rank real application SQL by cumulative execution time, with percentage contribution and noise filtering.
Area: Performance Tuning
Usage: Requires pg_stat_statements. Optional runtime filters without editing this file:
       SELECT set_config('pgdiag.min_calls','10',false);
       SELECT set_config('pgdiag.max_rows','10',false);
       SELECT set_config('pgdiag.min_exec_pct','30',false); -- optional: show only SQL >= 30% of total exec time
       SELECT set_config('pgdiag.query_filter','invoice',false);
       SELECT set_config('pgdiag.include_noise','on',false);
       -- Optional timestamp placeholders when using your own pg_stat_statements snapshot table:
       -- AND snapshot_ts >= timestamp '2026-05-10 09:00:00'
       -- AND snapshot_ts <  timestamp '2026-05-10 10:00:00'
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/

SELECT
    stats_reset AS pgss_stats_reset,
    clock_timestamp() - stats_reset AS statistics_age,
    'All following counters are cumulative since pgss_stats_reset; use snapshots for an incident interval.' AS measurement_boundary
FROM pg_stat_statements_info;

WITH params AS (
    SELECT
        coalesce(nullif(current_setting('pgdiag.min_calls', true), '')::bigint, 1) AS min_calls,
        coalesce(nullif(current_setting('pgdiag.max_rows', true), '')::integer, 10) AS max_rows,
        coalesce(nullif(current_setting('pgdiag.min_exec_pct', true), '')::numeric, 0) AS min_exec_pct,
        coalesce(nullif(current_setting('pgdiag.query_filter', true), ''), '') AS query_filter,
        coalesce(nullif(current_setting('pgdiag.include_noise', true), '')::boolean, false) AS include_noise
),
base AS (
    SELECT
        s.queryid,
        s.calls,
        s.total_exec_time,
        s.mean_exec_time,
        s.rows,
        s.shared_blks_hit,
        s.shared_blks_read,
        s.temp_blks_written,
        regexp_replace(s.query, '\s+', ' ', 'g') AS query_snippet
    FROM pg_stat_statements s
    CROSS JOIN params p
    WHERE s.calls >= p.min_calls
      AND (p.query_filter = '' OR s.query ILIKE '%' || p.query_filter || '%')
      AND (
          p.include_noise
          OR s.query !~* '^\s*(begin|commit|end|rollback|set|show|reset|discard|deallocate|analyze|vacuum)\b'
      )
      AND (
          p.include_noise
          OR s.query !~* '(pg_catalog|information_schema|pg_stat_activity|pg_show_all_settings|pg_settings|pg_backend_pid\(\)|set_config\()'
      )
),
totals AS (
    SELECT
        sum(total_exec_time) AS all_exec_ms,
        sum(calls) AS all_calls,
        sum(shared_blks_read) AS all_shared_reads,
        sum(temp_blks_written) AS all_temp_written
    FROM base
)
SELECT
    row_number() OVER (ORDER BY b.total_exec_time DESC) AS rank_by_total_time,
    b.queryid,
    b.calls,
    round((100.0 * b.calls / NULLIF(t.all_calls, 0))::numeric, 2) AS pct_calls,
    round(b.total_exec_time::numeric, 2) AS total_exec_ms,
    round((100.0 * b.total_exec_time / NULLIF(t.all_exec_ms, 0))::numeric, 2) AS pct_total_exec_time,
    round(b.mean_exec_time::numeric, 4) AS mean_exec_ms,
    b.rows,
    round((b.rows::numeric / NULLIF(b.calls, 0)), 2) AS rows_per_call,
    b.shared_blks_hit,
    b.shared_blks_read,
    round((100.0 * b.shared_blks_read / NULLIF(t.all_shared_reads, 0))::numeric, 2) AS pct_shared_reads,
    b.temp_blks_written,
    pg_size_pretty((b.temp_blks_written * current_setting('block_size')::bigint)) AS temp_written,
    round((100.0 * b.temp_blks_written / NULLIF(t.all_temp_written, 0))::numeric, 2) AS pct_temp_written,
    CASE
        WHEN b.temp_blks_written > 0 THEN 'Temp spill present; inspect sort/hash plans and work_mem scope.'
        WHEN b.shared_blks_read > b.shared_blks_hit THEN 'Read-heavy; check full scans, missing indexes, and cache/storage latency.'
        ELSE 'High total DB time; inspect EXPLAIN plan and business criticality.'
    END AS recommended_action,
    b.query_snippet
FROM base b
CROSS JOIN totals t
WHERE round((100.0 * b.total_exec_time / NULLIF(t.all_exec_ms, 0))::numeric, 2) >= (SELECT min_exec_pct FROM params)
ORDER BY b.total_exec_time DESC
LIMIT (SELECT max_rows FROM params);




-- SAMPLE_OUTPUT_BEGIN
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
-- ... remaining sample rows omitted; run the script for current environment-specific results.
-- SAMPLE_OUTPUT_END
