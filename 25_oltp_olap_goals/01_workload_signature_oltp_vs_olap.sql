/*
PostgreSQL DBA Script: Workload Signature OLTP Vs OLAP
Purpose: Classify statement patterns as OLTP-like or OLAP-like based on latency, volume, and rows/call.
Area: Optimization Goals (OLTP vs OLAP)
Usage: Requires pg_stat_statements; heuristic classification.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/

SELECT
    stats_reset AS pgss_stats_reset,
    clock_timestamp() - stats_reset AS statistics_age,
    'All following counters are cumulative since pgss_stats_reset; use snapshots for an incident interval.' AS measurement_boundary
FROM pg_stat_statements_info;

WITH base AS (
    SELECT
        queryid,
        calls,
        total_exec_time,
        mean_exec_time,
        rows,
        shared_blks_read,
        temp_blks_written,
        CASE WHEN calls = 0 THEN NULL ELSE rows::numeric / calls END AS rows_per_call,
        query AS query_snippet
    FROM pg_stat_statements
)
SELECT
    queryid,
    calls,
    mean_exec_time,
    rows_per_call,
    shared_blks_read,
    temp_blks_written,
    CASE
        WHEN calls >= 5000 AND mean_exec_time < 20 AND coalesce(rows_per_call, 0) <= 10 THEN 'OLTP-like'
        WHEN mean_exec_time >= 200 OR coalesce(rows_per_call, 0) >= 1000 OR temp_blks_written > 0 THEN 'OLAP-like'
        ELSE 'Mixed'
    END AS workload_class,
    query_snippet
FROM base
ORDER BY total_exec_time DESC
LIMIT 300;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--        queryid        |  calls  |     mean_exec_time     |       rows_per_call        | shared_blks_read | temp_blks_written | workload_class |                                                                                                                            query_snippet                                                                                                                             
-- ----------------------+---------+------------------------+----------------------------+------------------+-------------------+----------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   1144016440436625022 | 5332823 |     3.8100014295381928 |     1.00000000000000000000 |         10664795 |                 0 | OLTP-like      | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
--  -5371882943115234533 | 5332823 |    0.08268383982104996 |     1.00000000000000000000 |             1205 |                 0 | OLTP-like      | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
--   -305747636952590102 | 5332823 |   0.039258094757131864 |     1.00000000000000000000 |             1533 |                 0 | OLTP-like      | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
--   3387776431457662738 | 5332823 |   0.020229971087544072 |     1.00000000000000000000 |            19313 |                 0 | OLTP-like      | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
--  -1078345578982625442 | 5332823 |   0.006840656719152106 |     1.00000000000000000000 |               55 |                 0 | OLTP-like      | SELECT abalance FROM pgbench_accounts WHERE aid = $1
--   3481893718825960883 |    7109 |     2.8211766362357635 |         5.0000000000000000 |               97 |                 0 | OLTP-like      | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                                                                    +
--                       |         |                        |                            |                  |                   |                | FROM (SELECT                                                                                                                                                                                                                                                        +
--                       |         |                        |                            |                  |                   |                |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                                                                                                                       +
--                       |         |                        |                            |                  |                   |                |    (SELECT count(*) FROM pg_catalog.pg_s
--  -6652883949691502391 |       4 |          1162.38363525 |        250000.000000000000 |                4 |              1712 | OLAP-like      | INSERT INTO migration_v2_lab.child_events (account_id, event_type, amount)                                                                                                                                                                                          +
--                       |         |                        |                            |                  |                   |                | SELECT                                                                                                                                                                                                                                                              +
--                       |         |                        |                            |                  |                   |                |     ($1 + (random() * $2)::int)::bigint,                                                                                                                                                                                                                            +
--                       |         |                        |                            |                  |                   |                |     CASE WHEN gs % $3 = $4 THEN $5 WHEN gs % $6 = $7 THEN $8 ELSE $9 END,                                                                                                                                                                                           +
--                       |         |                        |                            |                  |                   |                |     round((random() * $10)::numeric, $11)                                                                                                                                                                                                                           +
--                       |         |                        |                            |                  |                   |                | FROM generate_series(
--  -8275299279783089467 |       4 |           1158.2690625 |     0.00000000000000000000 |                9 |              6426 | OLAP-like      | CREATE INDEX IF NOT EXISTS idx_v2_order_fact_search_lower                                                                                                                                                                                                           +
--                       |         |                        |                            |                  |                   |                |     ON migration_v2_lab.order_fact (lower(search_text))
--    847396262454713343 |       4 |            872.3010415 |        300000.000000000000 |                4 |              2052 | OLAP-like      | INSERT INTO migration_v2_lab.order_fact (account_id, filter_key, search_text, order_amount)                                                                                                                                                                         +
--                       |         |                        |                            |                  |                   |                | SELECT                                                                                                                                                                                                                                                              +
--                       |         |                        |                            |                  |                   |                |     ($1 + (random() * $2)::int)::bigint,                                                                                                                                                                                                                            +
--                       |         |                        |                            |                  |                   |                |     ($3 + (random() * $4)::int),                                                                                                                                                                                                                                    +
--                       |         |                        |                            |                  |                   |                |     CASE WHEN gs % $5 = $6 THEN $7 || gs ELSE $8 || gs END,                                                                                                                                                                                                         +
--                       |         |                        |                            |                  |                   |                |     round(($9 + random() * 
--  -3869797102397106429 |       4 |            770.5429585 |         90000.000000000000 |                4 |                 0 | OLAP-like      | INSERT INTO migration_v2_lab.bloat_pressure_table (payload)                                                                                                                                                                                                         +
--                       |         |                        |                            |                  |                   |                | SELECT repeat(md5(gs::text), $1)                                                                                                                                                                                                                                    +
--                       |         |                        |                            |                  |                   |                | FROM generate_series($2, $3) AS gs
--  -5065162101678021495 |       5 |             536.963942 |        156000.000000000000 |                5 |              1232 | OLAP-like      | INSERT INTO migration_v2_lab.stale_stats_table (payload)                                                                                                                                                                                                            +
--                       |         |                        |                            |                  |                   |                | SELECT md5(random()::text) || md5((random() * $1)::text)                                                                                                                                                                                                            +
--                       |         |                        |                            |                  |                   |                | FROM generate_series($2, $3)
--   7127220720807722591 |       4 |            543.9699475 |        120000.000000000000 |                4 |               824 | OLAP-like      | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)                                                                                                                                                                                                +
--                       |         |                        |                            |                  |                   |                | SELECT                                                                                                                                                                                                                                                              +
--                       |         |                        |                            |                  |                   |                |     ($1 + (random() * $2)::int)::bigint,                                                                                                                                                                                                                            +
--                       |         |                        |                            |                  |                   |                |     round((random() * $3)::numeric, $4)                                                                                                                                                                                                                             +
--                       |         |                        |                            |                  |                   |                | FROM generate_series($5, $6)
--   2285531965341755341 |       4 |           495.70377075 |        120000.000000000000 |              729 |                 0 | OLAP-like      | UPDATE migration_v2_lab.amount_mapping_risk                                                                                                                                                                                                                         +
--                       |         |                        |                            |                  |                   |                | SET                                                                                                                                                                                                                                                                 +
--                       |         |                        |                            |                  |                   |                |     target_int4_model = CASE                                                                                                                                                                                                                                        +
--                       |         |                        |                            |                  |                   |                |         WHEN abs(source_numeric) <= $1 THEN source_numeric::int                                                                                                                                                                                                     +
--                       |         |                        |                            |                  |                   |                |         ELSE target_int4_model                                                                                                                                                                                                                                      +
--                       |         |                        |                            |                  |                   |                |     END,                                                                                                                                                                                                                                                            +
-- ... remaining sample rows omitted; run the script for current environment-specific results.
-- SAMPLE_OUTPUT_END
