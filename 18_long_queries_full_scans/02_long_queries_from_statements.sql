/*
PostgreSQL DBA Script: Long Queries From Statements
Purpose: Rank historically slow queries using mean and total execution times.
Area: Long Queries and Full Scans
Usage: Requires pg_stat_statements.
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
    min_exec_time,
    max_exec_time,
    shared_blks_read,
    temp_blks_written,
    regexp_replace(query, '\s+', ' ', 'g') AS query_snippet
FROM pg_stat_statements
WHERE calls >= 5
ORDER BY mean_exec_time DESC
LIMIT 100;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--        queryid        |  calls  |  total_exec_time   |   mean_exec_time   |    min_exec_time     |   max_exec_time    | shared_blks_read | temp_blks_written |                                                                         query_snippet                                                                          
-- ----------------------+---------+--------------------+--------------------+----------------------+--------------------+------------------+-------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------
--  -5065162101678021495 |       5 |         2684.81971 |         536.963942 |           164.955125 |         648.070084 |                5 |              1232 | INSERT INTO migration_v2_lab.stale_stats_table (payload)                                                                                                      +
--                       |         |                    |                    |                      |                    |                  |                   | SELECT md5(random()::text) || md5((random() * $1)::text)                                                                                                      +
--                       |         |                    |                    |                      |                    |                  |                   | FROM generate_series($2, $3)
--   1459853053728673055 |       8 |        1851.923791 | 231.49047387500002 |           157.801125 |          308.55925 |                4 |                 0 | ANALYZE migration_v2_lab.order_fact
--    215870004070435986 |       8 | 1781.2664600000003 |        222.6583075 |           216.209042 |          227.68025 |               15 |                 0 | ANALYZE migration_v2_lab.partitioned_events
--  -2522370506372832129 |       8 |         935.383875 |      116.922984375 |           110.171083 |         122.844084 |              745 |                 0 | ANALYZE migration_v2_lab.customer_contact_compat
--  -4122962008160556687 |       6 |         662.406499 | 110.40108316666667 |           107.744458 |         112.704333 |                2 |                 0 | ANALYZE migration_v1_lab.stale_stats_table
--  -7376821209867977575 |       8 |         791.101833 |  98.88772912499999 |            95.769666 |         102.765416 |                1 |                 0 | ANALYZE migration_v2_lab.sales_catalog
--   1021157187189676460 |       8 |  674.5953319999999 |         84.3244165 |              82.1225 |          86.726875 |              466 |                 0 | ANALYZE migration_v2_lab.customer_staging_no_pk
--  -1900060566350483813 |       8 |  615.3488340000001 |        76.91860425 |             74.88675 |          78.801625 |              851 |                 0 | ANALYZE migration_v2_lab.parent_accounts
--   9120805628915790401 |       5 |         327.954707 |         65.5909414 |             7.049209 |          84.764791 |                5 |                 0 | INSERT INTO migration_v2_lab.parent_accounts (account_id, account_name)                                                                                       +
--                       |         |                    |                    |                      |                    |                  |                   | SELECT gs, $1 || gs                                                                                                                                           +
--                       |         |                    |                    |                      |                    |                  |                   | FROM generate_series($2, $3) AS gs
--   8710856124765966157 |       7 |         224.014083 |  32.00201185714286 |            27.919875 |           37.12075 |               48 |                 0 | SELECT                                                                                                                                                        +
--                       |         |                    |                    |                      |                    |                  |                   |     n.nspname AS schema_name,                                                                                                                                 +
--                       |         |                    |                    |                      |                    |                  |                   |     c.relname AS catalog_name,                                                                                                                                +
--                       |         |                    |                    |                      |                    |                  |                   |     c.relkind,                                                                                                                                                +
--                       |         |                    |                    |                      |                    |                  |                   |     pg_total_relation_size(c.oid) AS total_bytes,                                                                                                             +
--                       |         |                    |                    |                      |                    |                  |                   |     pg_size_pretty(pg_total_relation_size(c.oid)) AS total_pretty                                                                                             +
--                       |         |                    |                    |                      |                    |                  |                   | FROM pg_class c                                                                                                                                               +
--                       |         |                    |                    |                      |                    |                  |                   | JOIN pg_namespace n                                                                                                                                           +
--                       |         |                    |                    |                      |                    |                  |                   |     ON n.oid = c.relnamespace                                                                                                                                 +
--                       |         |                    |                    |                      |                    |                  |                   | WHERE n.nspname IN ($1 /*, ... */)                                                                                                                            +
--                       |         |                    |                    |                      |                    |                  |                   | ORDER BY total_bytes DESC
--   4446133009297590646 |       8 | 191.47212500000003 | 23.934015624999997 |            21.043334 |          30.123083 |             1596 |                 0 | ANALYZE migration_v2_lab.child_events
--  -6981156233023372390 |       6 |         130.565166 |          21.760861 |   18.299583000000002 |          24.022708 |                1 |                 0 | INSERT INTO tmp_pg360_check_results (                                                                                                                         +
--                       |         |                    |                    |                      |                    |                  |                   |     check_id,                                                                                                                                                 +
--                       |         |                    |                    |                      |                    |                  |                   |     area,                                                                                                                                                     +
--                       |         |                    |                    |                      |                    |                  |                   |     severity_if_failing,                                                                                                                                      +
--                       |         |                    |                    |                      |                    |                  |                   |     status,                                                                                                                                                   +
--                       |         |                    |                    |                      |                    |                  |                   |     issue_count,                                                                                                                                              +
--                       |         |                    |                    |                      |                    |                  |                   |     threshold_rule,                                                                                                                                           +
--                       |         |                    |                    |                      |                    |                  |                   |     evidence,                                                                                                                                                 +
--                       |         |                    |                    |                      |                    |                  |                   |     recommended_fix                                                                                                                                           +
--                       |         |                    |                    |                      |                    |                  |                   | )                                                                                                                                                             +
--                       |         |                    |                    |                      |                    |                  |                   | SELECT                                                                                                                                                        +
--                       |         |                    |                    |                      |                    |                  |                   |     $1,                                                                                                                                                       +
--                       |         |                    |                    |                      |                    |                  |                   |     $2,                                                                                                                                                       +
--                       |         |                    |                    |                      |                    |                  |                   |     $3,                                                                                                                                                       +
--                       |         |                    |                    |                      |                    |                  |                   |     CASE WHEN e.installed THEN $4 ELSE $5 END,                                                                                                                +
-- ... remaining sample rows omitted; run the script for current environment-specific results.
-- SAMPLE_OUTPUT_END
