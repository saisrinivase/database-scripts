/*
PostgreSQL DBA Script: Postupgrade Query Regression Watchlist Pg Stat Statements
Purpose: Build a post-upgrade query watchlist for plan/latency regressions using pg_stat_statements.
Area: Upgrade and Patch Readiness
Usage: Requires pg_stat_statements. Run before and after upgrade and compare top entries.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/

SELECT
    stats_reset AS pgss_stats_reset,
    clock_timestamp() - stats_reset AS statistics_age,
    'All following counters are cumulative since pgss_stats_reset; use snapshots for an incident interval.' AS measurement_boundary
FROM pg_stat_statements_info;

DROP TABLE IF EXISTS pg_temp.postupgrade_query_regression_watchlist_result;
CREATE TEMP TABLE pg_temp.postupgrade_query_regression_watchlist_result (
    queryid bigint,
    calls bigint,
    plans bigint,
    total_plan_time_ms numeric,
    total_exec_time_ms numeric,
    mean_exec_time_ms numeric,
    stddev_exec_time_ms numeric,
    plans_per_100_calls numeric,
    wal_bytes numeric,
    temp_blks_written bigint,
    shared_blks_read bigint,
    query_snippet text,
    regression_watch_label text
);

DO $$
BEGIN
    IF to_regclass('pg_stat_statements') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO pg_temp.postupgrade_query_regression_watchlist_result
            SELECT
                queryid,
                calls,
                plans,
                round(total_plan_time::numeric, 2),
                round(total_exec_time::numeric, 2),
                round(mean_exec_time::numeric, 2),
                round(stddev_exec_time::numeric, 2),
                round(CASE WHEN calls = 0 THEN 0 ELSE (plans::numeric / calls::numeric) * 100 END, 2),
                wal_bytes::numeric,
                temp_blks_written,
                shared_blks_read,
                query,
                CASE
                    WHEN stddev_exec_time > greatest(mean_exec_time * 2, 100) THEN 'HIGH_VARIANCE_REVIEW'
                    WHEN mean_exec_time > 500 THEN 'HIGH_MEAN_LATENCY_REVIEW'
                    WHEN temp_blks_written > 1024 THEN 'MEMORY_SPILL_REVIEW'
                    ELSE 'BASELINE_WATCH'
                END
            FROM pg_stat_statements
            WHERE calls >= 20
            ORDER BY total_exec_time DESC, stddev_exec_time DESC
            LIMIT 120
        $sql$;
    ELSE
        INSERT INTO pg_temp.postupgrade_query_regression_watchlist_result (
            query_snippet,
            regression_watch_label
        )
        VALUES (
            'pg_stat_statements extension is not installed. Run: CREATE EXTENSION pg_stat_statements;',
            'PG_STAT_STATEMENTS_MISSING'
        );
    END IF;
END;
$$;

SELECT *
FROM pg_temp.postupgrade_query_regression_watchlist_result;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--        queryid        |  calls  |  plans  | total_plan_time_ms | total_exec_time_ms | mean_exec_time_ms | stddev_exec_time_ms | plans_per_100_calls | wal_bytes  | temp_blks_written | shared_blks_read |                                                                 query_snippet                                                                 |  regression_watch_label  
-- ----------------------+---------+---------+--------------------+--------------------+-------------------+---------------------+---------------------+------------+-------------------+------------------+-----------------------------------------------------------------------------------------------------------------------------------------------+--------------------------
--   1144016440436625022 | 7727669 | 7727669 |          113201.16 |        21709355.83 |              2.81 |               76.71 |              100.00 | 1660034176 |                 0 |         15462165 | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2                                                                           | BASELINE_WATCH
--  -5371882943115234533 | 7727470 | 7727470 |           78823.30 |          472472.42 |              0.06 |                1.74 |              100.00 |  585129144 |                 0 |             1732 | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2                                                                           | BASELINE_WATCH
--   -305747636952590102 | 7727491 | 7727491 |           82342.27 |          242694.90 |              0.03 |                0.53 |              100.00 |  604851881 |                 0 |             1998 | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2                                                                            | BASELINE_WATCH
--   3387776431457662738 | 7727449 | 7727449 |           28485.22 |          123278.39 |              0.02 |                2.08 |              100.00 |  610471155 |                 0 |            22619 | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)                                          | BASELINE_WATCH
--  -1078345578982625442 | 7727506 | 7727506 |          101072.75 |           48400.31 |              0.01 |                0.04 |              100.00 |       3874 |                 0 |               98 | SELECT abalance FROM pgbench_accounts WHERE aid = $1                                                                                          | BASELINE_WATCH
--  -6127080060642381402 |      36 |      36 |               1.12 |           36092.24 |           1002.56 |               74.11 |              100.00 |          0 |             15408 |                4 | INSERT INTO partition_lab.fact_events_10y_unpartitioned (event_date, account_id, amount, payload)                                            +| HIGH_MEAN_LATENCY_REVIEW
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |             SELECT                                                                                                                           +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |                 ($1::date + ((gs - $2) % $3))::date AS event_date,                                                                           +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |                 ($4 + (gs % $5))::bi                                                                                                          | 
--   3481893718825960883 |    7109 |    7109 |           30091.34 |           20055.74 |              2.82 |              117.82 |              100.00 |          0 |                 0 |               97 | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                             +| HIGH_VARIANCE_REVIEW
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  | FROM (SELECT                                                                                                                                 +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid = $2)) AS "Total",+| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |                                                                                                                                               | 
--   3689806360888379158 | 1860000 |      54 |               0.91 |            1823.68 |              0.00 |                0.01 |                0.00 |   17714430 |                 0 |                0 | SELECT $2 FROM ONLY "migration_v2_lab"."parent_accounts" x WHERE "account_id" OPERATOR(pg_catalog.=) $1 FOR KEY SHARE OF x                    | BASELINE_WATCH
--  -3514466126412688923 |      29 |      29 |               5.02 |            1589.43 |             54.81 |               19.19 |              100.00 |          0 |                 0 |                4 | SELECT COALESCE(queryid::text, $1) AS queryid,                                                                                               +| BASELINE_WATCH
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |                    calls::numeric AS calls,                                                                                                  +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |                    total_exec_time::numeric AS total_exec_ms,                                                                                +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |                    mean_exec_time::numeric AS avg_exec_ms,                                                                                   +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |                                                                                                                                               | 
--   1901987179462105607 |      67 |      67 |              26.76 |             896.43 |             13.38 |                6.82 |              100.00 |          0 |                 0 |               44 | SELECT datname,                                                                                                                              +| BASELINE_WATCH
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |        datallowconn,                                                                                                                         +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |        datconnlimit,                                                                                                                         +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |        pg_encoding_to_char(encoding) AS encoding,                                                                                            +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |        datcollate,                                                                                                                           +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |        datctype,                                                                                                                             +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |        pg_size_pretty(pg_database_size(datname)) AS database_size                                                                            +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  | FROM pg_da                                                                                                                                    | 
--   6097083398544187049 | 7727416 |       0 |               0.00 |             857.36 |              0.00 |                0.00 |                0.00 |          0 |                 0 |                0 | END                                                                                                                                           | BASELINE_WATCH
--   4854991825702068830 | 7727688 |       0 |               0.00 |             844.52 |              0.00 |                0.00 |                0.00 |          0 |                 0 |                0 | BEGIN                                                                                                                                         | BASELINE_WATCH
--  -2039736649399175093 |      31 |      31 |              59.72 |             470.57 |             15.18 |               13.55 |              100.00 |          0 |                 0 |                0 | SELECT datname,                                                                                                                              +| BASELINE_WATCH
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |        pg_size_pretty(pg_database_size(datname)) AS database_size,                                                                           +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |        pg_database_size(datname) AS database_bytes                                                                                           +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  | FROM pg_database                                                                                                                             +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  | ORDER BY database_bytes DESC                                                                                                                  | 
--   3689806360888379158 |  480000 |      24 |               0.33 |             374.34 |              0.00 |                0.00 |                0.01 |    2160000 |                 0 |                0 | SELECT $2 FROM ONLY "migration_v1_lab"."parent_accounts" x WHERE "account_id" OPERATOR(pg_catalog.=) $1 FOR KEY SHARE OF x                    | BASELINE_WATCH
--  -2613308585781804763 |      49 |      49 |              26.19 |             373.97 |              7.63 |                5.36 |              100.00 |          0 |                 0 |                0 | SELECT name FROM pg_available_extensions ORDER BY name                                                                                        | BASELINE_WATCH
--   7603979851483574365 |      53 |      53 |               3.34 |             358.29 |              6.76 |                6.13 |              100.00 |          0 |                 0 |                0 | SELECT s.dbid,                                                                                                                               +| BASELINE_WATCH
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |        d.datname,                                                                                                                            +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |        s.queryid,                                                                                                                            +| 
--                       |         |         |                    |                    |                   |                     |                     |            |                   |                  |        s.calls,                                                                                                                              +| 
-- ... remaining sample rows omitted; run the script for current environment-specific results.
-- SAMPLE_OUTPUT_END
