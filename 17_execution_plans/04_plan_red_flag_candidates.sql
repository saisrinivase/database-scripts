/*
PostgreSQL DBA Script: Plan Red Flag Candidates
Purpose: Flag statements likely to have plan-level issues (spills, I/O-heavy, high variance).
Area: Execution Plans
Usage: Requires pg_stat_statements; candidate list for deeper EXPLAIN ANALYZE.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/

SELECT
    stats_reset AS pgss_stats_reset,
    clock_timestamp() - stats_reset AS statistics_age,
    'All following counters are cumulative since pgss_stats_reset; use snapshots for an incident interval.' AS measurement_boundary
FROM pg_stat_statements_info;

SELECT
    queryid,
    calls,
    total_exec_time,
    mean_exec_time,
    stddev_exec_time,
    shared_blks_hit,
    shared_blks_read,
    temp_blks_written,
    CASE
        WHEN temp_blks_written > 100000 THEN 'Temp spill risk'
        WHEN shared_blks_read > shared_blks_hit THEN 'I/O heavy plan risk'
        WHEN stddev_exec_time > mean_exec_time THEN 'Unstable plan/runtime variance'
        WHEN mean_exec_time > 1000 THEN 'High latency plan review'
        ELSE 'Observe'
    END AS recommendation,
    query AS query_snippet
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 200;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--        queryid        |  calls  |  total_exec_time   |     mean_exec_time     |   stddev_exec_time    | shared_blks_hit | shared_blks_read | temp_blks_written |         recommendation         |                                                                                                        query_snippet                                                                                                         
-- ----------------------+---------+--------------------+------------------------+-----------------------+-----------------+------------------+-------------------+--------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   1144016440436625022 | 5332823 | 20318063.253471453 |     3.8100014295381928 |     92.32002420399405 |        45639018 |         10664795 |                 0 | Unstable plan/runtime variance | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
--  -5371882943115234533 | 5332823 |  440938.2827256841 |    0.08268383982104996 |    2.0963843383810876 |        30081894 |             1205 |                 0 | Unstable plan/runtime variance | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
--   -305747636952590102 | 5332823 | 209356.47065673055 |   0.039258094757131864 |     0.625514976433878 |        27087536 |             1533 |                 0 | Unstable plan/runtime variance | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
--   3387776431457662738 | 5332823 | 107882.85510483896 |   0.020229971087544072 |    2.4970450599666827 |         5534382 |            19313 |                 0 | Unstable plan/runtime variance | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
--  -1078345578982625442 | 5332823 |  36480.01148695377 |   0.006840656719152106 |   0.05010911945496172 |        29324806 |               55 |                 0 | Unstable plan/runtime variance | SELECT abalance FROM pgbench_accounts WHERE aid = $1
--   3481893718825960883 |    7109 |  20055.74470699987 |     2.8211766362357635 |    117.82179113781538 |          216589 |               97 |                 0 | Unstable plan/runtime variance | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                                                                            +
--                       |         |                    |                        |                       |                 |                  |                   |                                | FROM (SELECT                                                                                                                                                                                                                +
--                       |         |                    |                        |                       |                 |                  |                   |                                |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",                                                                               +
--                       |         |                    |                        |                       |                 |                  |                   |                                | 
--  -6652883949691502391 |       4 |        4649.534541 |          1162.38363525 |     42.79538066978084 |         8620939 |                4 |              1712 | High latency plan review       | INSERT INTO migration_v2_lab.child_events (account_id, event_type, amount)                                                                                                                                                  +
--                       |         |                    |                        |                       |                 |                  |                   |                                | SELECT                                                                                                                                                                                                                      +
--                       |         |                    |                        |                       |                 |                  |                   |                                |     ($1 + (random() * $2)::int)::bigint,                                                                                                                                                                                    +
--                       |         |                    |                        |                       |                 |                  |                   |                                |     CASE WHEN gs % $3 = $4 THEN $5 WHEN gs % $6 = $7 THEN $8 ELSE $9 END,                                                                                                                                                   +
--                       |         |                    |                        |                       |                 |                  |                   |                                |     round((random() * $
--  -8275299279783089467 |       4 |         4633.07625 |           1158.2690625 |    16.886863587328616 |           14272 |                9 |              6426 | High latency plan review       | CREATE INDEX IF NOT EXISTS idx_v2_order_fact_search_lower                                                                                                                                                                   +
--                       |         |                    |                        |                       |                 |                  |                   |                                |     ON migration_v2_lab.order_fact (lower(search_text))
--    847396262454713343 |       4 |        3489.204166 |            872.3010415 |     42.84847753099274 |         4234736 |                4 |              2052 | Observe                        | INSERT INTO migration_v2_lab.order_fact (account_id, filter_key, search_text, order_amount)                                                                                                                                 +
--                       |         |                    |                        |                       |                 |                  |                   |                                | SELECT                                                                                                                                                                                                                      +
--                       |         |                    |                        |                       |                 |                  |                   |                                |     ($1 + (random() * $2)::int)::bigint,                                                                                                                                                                                    +
--                       |         |                    |                        |                       |                 |                  |                   |                                |     ($3 + (random() * $4)::int),                                                                                                                                                                                            +
--                       |         |                    |                        |                       |                 |                  |                   |                                |     CASE WHEN gs % $5 = $6 THEN $7 || gs ELSE $
--  -3869797102397106429 |       4 |        3082.171834 |            770.5429585 |    18.695471356005665 |         1451244 |                4 |                 0 | Observe                        | INSERT INTO migration_v2_lab.bloat_pressure_table (payload)                                                                                                                                                                 +
--                       |         |                    |                        |                       |                 |                  |                   |                                | SELECT repeat(md5(gs::text), $1)                                                                                                                                                                                            +
--                       |         |                    |                        |                       |                 |                  |                   |                                | FROM generate_series($2, $3) AS gs
--  -5065162101678021495 |       5 |         2684.81971 |             536.963942 |    186.65567429538393 |         3021548 |                5 |              1232 | Observe                        | INSERT INTO migration_v2_lab.stale_stats_table (payload)                                                                                                                                                                    +
--                       |         |                    |                        |                       |                 |                  |                   |                                | SELECT md5(random()::text) || md5((random() * $1)::text)                                                                                                                                                                    +
--                       |         |                    |                        |                       |                 |                  |                   |                                | FROM generate_series($2, $3)
--   7127220720807722591 |       4 |         2175.87979 |            543.9699475 |    43.367792728474654 |         4326932 |                4 |               824 | Observe                        | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)                                                                                                                                                        +
--                       |         |                    |                        |                       |                 |                  |                   |                                | SELECT                                                                                                                                                                                                                      +
--                       |         |                    |                        |                       |                 |                  |                   |                                |     ($1 + (random() * $2)::int)::bigint,                                                                                                                                                                                    +
--                       |         |                    |                        |                       |                 |                  |                   |                                |     round((random() * $3)::numeric, $4)                                                                                                                                                                                     +
--                       |         |                    |                        |                       |                 |                  |                   |                                | FROM generate_series($5, $6)
--   2285531965341755341 |       4 |        1982.815083 |           495.70377075 |     89.52999103880009 |         3259947 |              729 |                 0 | Observe                        | UPDATE migration_v2_lab.amount_mapping_risk                                                                                                                                                                                 +
--                       |         |                    |                        |                       |                 |                  |                   |                                | SET                                                                                                                                                                                                                         +
--                       |         |                    |                        |                       |                 |                  |                   |                                |     target_int4_model = CASE                                                                                                                                                                                                +
--                       |         |                    |                        |                       |                 |                  |                   |                                |         WHEN abs(source_numeric) <= $1 THEN source_numeric::int                                                                                                                                                             +
--                       |         |                    |                        |                       |                 |                  |                   |                                |         ELSE target_int4_model                                                                                                                                                                                              +
--                       |         |                    |                        |                       |                 |                  |                   |                                |     END,                                                                                                                                                                                                                    +
--                       |         |                    |                        |                       |                 |                  |                   |                                |     target_bigint_model = source_numeri
--   1459853053728673055 |       8 |        1851.923791 |     231.49047387500002 |     71.71435727126972 |           27943 |                4 |                 0 | Observe                        | ANALYZE migration_v2_lab.order_fact
-- ... remaining sample rows omitted; run the script for current environment-specific results.
-- SAMPLE_OUTPUT_END
