/*
PostgreSQL DBA Script: OLAP Throughput Candidates
Purpose: Detect analytic-style statements with heavy scans and high resource use.
Area: Optimization Goals (OLTP vs OLAP)
Usage: Candidate list for partitioning, pre-aggregation, or materialized views.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    queryid,
    calls,
    total_exec_time,
    mean_exec_time,
    shared_blks_read,
    temp_blks_written,
    rows,
    query AS query_snippet
FROM pg_stat_statements
WHERE mean_exec_time >= 200
   OR shared_blks_read >= 100000
   OR temp_blks_written > 0
ORDER BY total_exec_time DESC
LIMIT 200;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--        queryid        |  calls  |  total_exec_time   |   mean_exec_time   | shared_blks_read | temp_blks_written |  rows   |                                                           query_snippet                                                            
-- ----------------------+---------+--------------------+--------------------+------------------+-------------------+---------+------------------------------------------------------------------------------------------------------------------------------------
--   1144016440436625022 | 5332823 | 20318063.253471453 | 3.8100014295381928 |         10664795 |                 0 | 5332823 | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
--  -6652883949691502391 |       4 |        4649.534541 |      1162.38363525 |                4 |              1712 | 1000000 | INSERT INTO migration_v2_lab.child_events (account_id, event_type, amount)                                                        +
--                       |         |                    |                    |                  |                   |         | SELECT                                                                                                                            +
--                       |         |                    |                    |                  |                   |         |     ($1 + (random() * $2)::int)::bigint,                                                                                          +
--                       |         |                    |                    |                  |                   |         |     CASE WHEN gs % $3 = $4 THEN $5 WHEN gs % $6 = $7 THEN $8 ELSE $9 END,                                                         +
--                       |         |                    |                    |                  |                   |         |     round((random() * $10)::numeric, $11)                                                                                         +
--                       |         |                    |                    |                  |                   |         | FROM generate_series(
--  -8275299279783089467 |       4 |         4633.07625 |       1158.2690625 |                9 |              6426 |       0 | CREATE INDEX IF NOT EXISTS idx_v2_order_fact_search_lower                                                                         +
--                       |         |                    |                    |                  |                   |         |     ON migration_v2_lab.order_fact (lower(search_text))
--    847396262454713343 |       4 |        3489.204166 |        872.3010415 |                4 |              2052 | 1200000 | INSERT INTO migration_v2_lab.order_fact (account_id, filter_key, search_text, order_amount)                                       +
--                       |         |                    |                    |                  |                   |         | SELECT                                                                                                                            +
--                       |         |                    |                    |                  |                   |         |     ($1 + (random() * $2)::int)::bigint,                                                                                          +
--                       |         |                    |                    |                  |                   |         |     ($3 + (random() * $4)::int),                                                                                                  +
--                       |         |                    |                    |                  |                   |         |     CASE WHEN gs % $5 = $6 THEN $7 || gs ELSE $8 || gs END,                                                                       +
--                       |         |                    |                    |                  |                   |         |     round(($9 + random() * 
--  -3869797102397106429 |       4 |        3082.171834 |        770.5429585 |                4 |                 0 |  360000 | INSERT INTO migration_v2_lab.bloat_pressure_table (payload)                                                                       +
--                       |         |                    |                    |                  |                   |         | SELECT repeat(md5(gs::text), $1)                                                                                                  +
--                       |         |                    |                    |                  |                   |         | FROM generate_series($2, $3) AS gs
--  -5065162101678021495 |       5 |         2684.81971 |         536.963942 |                5 |              1232 |  780000 | INSERT INTO migration_v2_lab.stale_stats_table (payload)                                                                          +
--                       |         |                    |                    |                  |                   |         | SELECT md5(random()::text) || md5((random() * $1)::text)                                                                          +
--                       |         |                    |                    |                  |                   |         | FROM generate_series($2, $3)
--   7127220720807722591 |       4 |         2175.87979 |        543.9699475 |                4 |               824 |  480000 | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)                                                              +
--                       |         |                    |                    |                  |                   |         | SELECT                                                                                                                            +
--                       |         |                    |                    |                  |                   |         |     ($1 + (random() * $2)::int)::bigint,                                                                                          +
--                       |         |                    |                    |                  |                   |         |     round((random() * $3)::numeric, $4)                                                                                           +
--                       |         |                    |                    |                  |                   |         | FROM generate_series($5, $6)
--   2285531965341755341 |       4 |        1982.815083 |       495.70377075 |              729 |                 0 |  480000 | UPDATE migration_v2_lab.amount_mapping_risk                                                                                       +
--                       |         |                    |                    |                  |                   |         | SET                                                                                                                               +
--                       |         |                    |                    |                  |                   |         |     target_int4_model = CASE                                                                                                      +
--                       |         |                    |                    |                  |                   |         |         WHEN abs(source_numeric) <= $1 THEN source_numeric::int                                                                   +
--                       |         |                    |                    |                  |                   |         |         ELSE target_int4_model                                                                                                    +
--                       |         |                    |                    |                  |                   |         |     END,                                                                                                                          +
--                       |         |                    |                    |                  |                   |         |     target_bigint_model = source_numeric::bigint                                                                                  +
--                       |         |                    |                    |                  |                   |         | WHERE target_bigint_model IS N
--   1459853053728673055 |       8 |        1851.923791 | 231.49047387500002 |                4 |                 0 |       0 | ANALYZE migration_v2_lab.order_fact
--    215870004070435986 |       8 | 1781.2664600000003 |        222.6583075 |               15 |                 0 |       0 | ANALYZE migration_v2_lab.partitioned_events
--    450201137788272562 |       1 |        1674.504167 |        1674.504167 |            29989 |                 0 |       0 | ANALYZE
--   7127220720807722591 |       3 |        1636.255042 |  545.4183473333334 |                3 |               618 |  360000 | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)                                                              +
--                       |         |                    |                    |                  |                   |         | SELECT                                                                                                                            +
--                       |         |                    |                    |                  |                   |         |     ($1 + (random() * $2)::int)::bigint,                                                                                          +
--                       |         |                    |                    |                  |                   |         |     round((random() * $3)::numeric, $4)                                                                                           +
--                       |         |                    |                    |                  |                   |         | FROM generate_series($5, $6)
--  -1479418139676470911 |       4 |        1535.621918 |        383.9054795 |                0 |                 0 |       0 | CREATE INDEX idx_v2_sales_ref_b ON migration_v2_lab.sales_catalog (item_ref)
--   4361856503355632769 |       4 | 1521.6664580000001 | 380.41661450000004 |                0 |                 0 |       0 | CREATE INDEX idx_v2_sales_ref_a ON migration_v2_lab.sales_catalog (item_ref)
--   4667898782383165389 |       4 |        1190.093041 |       297.52326025 |                4 |               824 |  480000 | INSERT INTO migration_v2_lab.sales_catalog (item_ref, item_type, price)                                                           +
--                       |         |                    |                    |                  |                   |         | SELECT                                                                                                                            +
--                       |         |                    |                    |                  |                   |         |     $1 || gs,                                                                                                                     +
--                       |         |                    |                    |                  |                   |         |     CASE WHEN gs % $2 = $3 THEN $4 WHEN gs % $5 = $6 THEN $7 WHEN gs % $8 = $9 THEN $10 WHEN gs % $11 = $12 THEN $13 ELSE $14 END,+
--                       |         |                    |                    |                  |                   |         |     round(($15 + random() * $16)::nu
--  -4598960938853719316 |       4 |          1100.3515 | 275.08787499999994 |                4 |                 0 |  100000 | INSERT INTO migration_v1_lab.dml_bloat_table (payload)                                                                            +
--                       |         |                    |                    |                  |                   |         | SELECT repeat(md5(gs::text), $1)                                                                                                  +
--                       |         |                    |                    |                  |                   |         | FROM generate_series($2, $3) AS gs
--  -5938169015537755073 |       4 |        1016.337374 | 254.08434350000002 |                8 |                 0 |  400000 | INSERT INTO migration_v2_lab.partitioned_events (event_date, event_payload)                                                       +
--                       |         |                    |                    |                  |                   |         | SELECT                                                                                                                            +
--                       |         |                    |                    |                  |                   |         |     date $1 + (gs % $2),                                                                                                          +
--                       |         |                    |                    |                  |                   |         |     md5(gs::text)                                                                                                                 +
--                       |         |                    |                    |                  |                   |         | FROM generate_series($3, $4) AS gs
--   1579180460630060410 |       4 |  903.8009159999999 |         225.950229 |                4 |               824 |  480000 | INSERT INTO migration_v2_lab.amount_mapping_risk (source_numeric, target_int4_model)                                              +
--                       |         |                    |                    |                  |                   |         | SELECT                                                                                                                            +
--                       |         |                    |                    |                  |                   |         |     CASE                                                                                                                          +
--                       |         |                    |                    |                  |                   |         |         WHEN gs % $1 = $2 THEN $3 + gs                                                                                            +
--                       |         |                    |                    |                  |                   |         |         WHEN gs % $4 = $5 THEN $6 - gs                                                                                            +
--                       |         |                    |                    |                  |                   |         |         ELSE gs::numeric                                                                                                          +
--                       |         |                    |                    |                  |                   |         |     END,                                                                                                                          +
--                       |         |                    |                    |                  |                   |         |     $7                                                                                                                            +
--                       |         |                    |                    |                  |                   |         | FROM generate_series($8, $9) AS gs
--  -4598960938853719316 |       3 |          835.59025 |  278.5300833333333 |                3 |                 0 |   75000 | INSERT INTO migration_v1_lab.dml_bloat_table (payload)                                                                            +
--                       |         |                    |                    |                  |                   |         | SELECT repeat(md5(gs::text), $1)                                                                                                  +
--                       |         |                    |                    |                  |                   |         | FROM generate_series($2, $3) AS gs
--  -5398677000037045473 |       1 |         802.498625 |         802.498625 |            53105 |                 0 |       0 | CREATE DATABASE script_validation_20260218_172749 TEMPLATE perf_test
--   7127220720807722591 |       1 |         618.777208 |         618.777208 |                1 |               206 |  120000 | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)                                                              +
--                       |         |                    |                    |                  |                   |         | SELECT                                                                                                                            +
--                       |         |                    |                    |                  |                   |         |     ($1 + (random() * $2)::int)::bigint,                                                                                          +
--                       |         |                    |                    |                  |                   |         |     round((random() * $3)::numeric, $4)                                                                                           +
--                       |         |                    |                    |                  |                   |         | FROM generate_series($5, $6)
--  -4598960938853719316 |       1 | 255.13079199999999 | 255.13079199999999 |                1 |                 0 |   25000 | INSERT INTO migration_v1_lab.dml_bloat_table (payload)                                                                            +
--                       |         |                    |                    |                  |                   |         | SELECT repeat(md5(gs::text), $1)                                                                                                  +
--                       |         |                    |                    |                  |                   |         | FROM generate_series($2, $3) AS gs
--  -8708022775858244193 |       4 | 183.60700000000003 |  45.90175000000001 |                0 |              2940 |       0 | CREATE INDEX IF NOT EXISTS idx_v2_order_fact_filter_key                                                                           +
--                       |         |                    |                    |                  |                   |         |     ON migration_v2_lab.order_fact (filter_key)
--   1114623876772974445 |       4 |         146.180208 |          36.545052 |             1336 |              2449 |       0 | CREATE INDEX IF NOT EXISTS idx_v2_child_events_account_id                                                                         +
--                       |         |                    |                    |                  |                   |         |     ON migration_v2_lab.child_events (account_id)
-- (24 rows)
-- 
-- SAMPLE_OUTPUT_END
