/*
PostgreSQL DBA Script: Slow Query Log Vs Pg Stat Statements Correlation
Purpose: Correlate slow-query logging threshold with pg_stat_statements hotspots.
Area: Logging and Error Signatures
Usage: Requires pg_stat_statements. Helps decide whether logging threshold is missing key queries.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/

SELECT
    stats_reset AS pgss_stats_reset,
    clock_timestamp() - stats_reset AS statistics_age,
    'All following counters are cumulative since pgss_stats_reset; use snapshots for an incident interval.' AS measurement_boundary
FROM pg_stat_statements_info;

DROP TABLE IF EXISTS pg_temp.slow_query_log_vs_pgss_result;
CREATE TEMP TABLE pg_temp.slow_query_log_vs_pgss_result (
    queryid bigint,
    calls bigint,
    total_exec_time_ms numeric,
    mean_exec_time_ms numeric,
    stddev_exec_time_ms numeric,
    temp_blks_written bigint,
    shared_blks_read bigint,
    log_min_duration_statement text,
    log_visibility text,
    query_snippet text
);

DO $$
BEGIN
    IF to_regclass('pg_stat_statements') IS NOT NULL THEN
        EXECUTE $sql$
            WITH cfg AS (
                SELECT
                    current_setting('log_min_duration_statement') AS raw_setting,
                    CASE
                        WHEN current_setting('log_min_duration_statement') ~ '^-?[0-9]+$'
                            THEN current_setting('log_min_duration_statement')::numeric
                        ELSE NULL::numeric
                    END AS threshold_ms
            ),
            ranked AS (
                SELECT
                    queryid,
                    calls,
                    total_exec_time,
                    mean_exec_time,
                    stddev_exec_time,
                    temp_blks_written,
                    shared_blks_read,
                    query AS query_snippet
                FROM pg_stat_statements
                ORDER BY total_exec_time DESC
                LIMIT 50
            )
            INSERT INTO pg_temp.slow_query_log_vs_pgss_result
            SELECT
                r.queryid,
                r.calls,
                round(r.total_exec_time::numeric, 2),
                round(r.mean_exec_time::numeric, 2),
                round(r.stddev_exec_time::numeric, 2),
                r.temp_blks_written,
                r.shared_blks_read,
                c.raw_setting,
                CASE
                    WHEN c.threshold_ms = -1 THEN 'NOT_LOGGED'
                    WHEN c.threshold_ms = 0 THEN 'LOGGED_ALWAYS'
                    WHEN r.mean_exec_time >= c.threshold_ms THEN 'LIKELY_LOGGED'
                    ELSE 'LIKELY_NOT_LOGGED'
                END,
                r.query_snippet
            FROM ranked r
            CROSS JOIN cfg c
            ORDER BY r.total_exec_time DESC
        $sql$;
    ELSE
        INSERT INTO pg_temp.slow_query_log_vs_pgss_result (log_visibility, query_snippet)
        VALUES ('PG_STAT_STATEMENTS_MISSING', 'pg_stat_statements extension is not installed. Run: CREATE EXTENSION pg_stat_statements;');
    END IF;
END;
$$;

SELECT *
FROM pg_temp.slow_query_log_vs_pgss_result;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--        queryid        |  calls  | total_exec_time_ms | mean_exec_time_ms | stddev_exec_time_ms | temp_blks_written | shared_blks_read | log_min_duration_statement | log_visibility |                                                                           query_snippet                                                                           
-- ----------------------+---------+--------------------+-------------------+---------------------+-------------------+------------------+----------------------------+----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   1144016440436625022 | 7727669 |        21709355.83 |              2.81 |               76.71 |                 0 |         15462165 | -1                         | NOT_LOGGED     | UPDATE pgbench_accounts SET abalance = abalance + $1 WHERE aid = $2
--  -5371882943115234533 | 7727470 |          472472.42 |              0.06 |                1.74 |                 0 |             1732 | -1                         | NOT_LOGGED     | UPDATE pgbench_branches SET bbalance = bbalance + $1 WHERE bid = $2
--   -305747636952590102 | 7727491 |          242694.90 |              0.03 |                0.53 |                 0 |             1998 | -1                         | NOT_LOGGED     | UPDATE pgbench_tellers SET tbalance = tbalance + $1 WHERE tid = $2
--   3387776431457662738 | 7727449 |          123278.39 |              0.02 |                2.08 |                 0 |            22619 | -1                         | NOT_LOGGED     | INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
--  -1078345578982625442 | 7727506 |           48400.31 |              0.01 |                0.04 |                 0 |               98 | -1                         | NOT_LOGGED     | SELECT abalance FROM pgbench_accounts WHERE aid = $1
--   -214248046822219685 |       2 |           37841.83 |          18920.92 |             1072.63 |             15408 |          1313283 | -1                         | NOT_LOGGED     | DO $$                                                                                                                                                            +
--                       |         |                    |                   |                     |                   |                  |                            |                | DECLARE                                                                                                                                                          +
--                       |         |                    |                   |                     |                   |                  |                            |                |     v_schema text;                                                                                                                                               +
--                       |         |                    |                   |                     |                   |                  |                            |                |     v_table text;                                                                                                                                                +
--                       |         |                    |                   |                     |                   |                  |                            |                |     v_history_years int;                                                                                                                                         +
--                       |         |                    |                   |                     |                   |                  |                            |                |     v_target_gb numeric;                                                                                                                                         +
--                       |         |                    |                   |                     |                   |                  |                            |                |     v_payload_bytes int;                                                                                                                                         +
--                       |         |                    |                   |                     |                   |                  |                            |                |     v_batch_rows int;                                                                                                                                            +
--                       |         |                    |                   |                     |                   |                  |                            |                |     v_target_bytes bigint;                                                                                                                                       +
--                       |         |                    |                   |                     |                   |                  |                            |                |     v_start_date date;                                                                                                                                           +
--                       |         |                    |                   |                     |                   |                  |                            |                |   
--  -6127080060642381402 |      36 |           36092.24 |           1002.56 |               74.11 |             15408 |                4 | -1                         | NOT_LOGGED     | INSERT INTO partition_lab.fact_events_10y_unpartitioned (event_date, account_id, amount, payload)                                                                +
--                       |         |                    |                   |                     |                   |                  |                            |                |             SELECT                                                                                                                                               +
--                       |         |                    |                   |                     |                   |                  |                            |                |                 ($1::date + ((gs - $2) % $3))::date AS event_date,                                                                                               +
--                       |         |                    |                   |                     |                   |                  |                            |                |                 
--   3481893718825960883 |    7109 |           20055.74 |              2.82 |              117.82 |                 0 |               97 | -1                         | NOT_LOGGED     | SELECT $1 AS chart_name, pg_catalog.row_to_json(t) AS chart_data                                                                                                 +
--                       |         |                    |                   |                     |                   |                  |                            |                | FROM (SELECT                                                                                                                                                     +
--                       |         |                    |                   |                     |                   |                  |                            |                |    (SELECT count(*) FROM pg_catalog.pg_stat_activity WHERE datname = (SELECT datname FROM pg_catalog.pg_database WHERE oid
--  -8275299279783089467 |       6 |            6922.60 |           1153.77 |               19.76 |              9640 |               17 | -1                         | NOT_LOGGED     | CREATE INDEX IF NOT EXISTS idx_v2_order_fact_search_lower                                                                                                        +
--                       |         |                    |                   |                     |                   |                  |                            |                |     ON migration_v2_lab.order_fact (lower(search_text))
--  -6652883949691502391 |       6 |            6777.13 |           1129.52 |               81.19 |              2568 |                6 | -1                         | NOT_LOGGED     | INSERT INTO migration_v2_lab.child_events (account_id, event_type, amount)                                                                                       +
--                       |         |                    |                   |                     |                   |                  |                            |                | SELECT                                                                                                                                                           +
--                       |         |                    |                   |                     |                   |                  |                            |                |     ($1 + (random() * $2)::int)::bigint,                                                                                                                         +
--                       |         |                    |                   |                     |                   |                  |                            |                |     CASE WHEN gs % $3 = $4 THEN $5 WHEN gs % $6 = $7 THEN $8 ELSE $9 END,                                                                                        +
--                       |         |                    |                   |                     |                   |                  |                            |                |    
--    847396262454713343 |       6 |            4926.30 |            821.05 |              125.01 |              3078 |                6 | -1                         | NOT_LOGGED     | INSERT INTO migration_v2_lab.order_fact (account_id, filter_key, search_text, order_amount)                                                                      +
--                       |         |                    |                   |                     |                   |                  |                            |                | SELECT                                                                                                                                                           +
--                       |         |                    |                   |                     |                   |                  |                            |                |     ($1 + (random() * $2)::int)::bigint,                                                                                                                         +
--                       |         |                    |                   |                     |                   |                  |                            |                |     ($3 + (random() * $4)::int),                                                                                                                                 +
--                       |         |                    |                   |                     |                   |                  |                            |                |     CASE WHEN gs % $5 = $6 
--  -3869797102397106429 |       6 |            4568.00 |            761.33 |               33.40 |                 0 |                6 | -1                         | NOT_LOGGED     | INSERT INTO migration_v2_lab.bloat_pressure_table (payload)                                                                                                      +
--                       |         |                    |                   |                     |                   |                  |                            |                | SELECT repeat(md5(gs::text), $1)                                                                                                                                 +
--                       |         |                    |                   |                     |                   |                  |                            |                | FROM generate_series($2, $3) AS gs
--  -5065162101678021495 |       9 |            4116.56 |            457.40 |              217.63 |              1848 |                9 | -1                         | NOT_LOGGED     | INSERT INTO migration_v2_lab.stale_stats_table (payload)                                                                                                         +
--                       |         |                    |                   |                     |                   |                  |                            |                | SELECT md5(random()::text) || md5((random() * $1)::text)                                                                                                         +
-- ... remaining sample rows omitted; run the script for current environment-specific results.
-- SAMPLE_OUTPUT_END
