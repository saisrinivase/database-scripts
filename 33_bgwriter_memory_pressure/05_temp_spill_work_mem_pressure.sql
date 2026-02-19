/*
Purpose: Identify memory-pressure symptoms from temp spill volume and work_mem-sensitive query behavior.
Area: Background Processes and Memory Pressure
Usage: Use alongside EXPLAIN to tune work_mem and query plans safely.
*/
SELECT CASE
           WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN 1
           ELSE 0
       END AS has_pgss
\gset

WITH cfg AS (
    SELECT
        current_setting('work_mem') AS work_mem,
        current_setting('maintenance_work_mem') AS maintenance_work_mem,
        current_setting('temp_file_limit', true) AS temp_file_limit
),
db AS (
    SELECT
        datname,
        temp_files,
        temp_bytes,
        xact_commit + xact_rollback AS total_xacts,
        stats_reset
    FROM pg_stat_database
    WHERE datname = current_database()
)
SELECT
    d.datname AS database_name,
    c.work_mem,
    c.maintenance_work_mem,
    coalesce(c.temp_file_limit, '(not set)') AS temp_file_limit,
    d.temp_files,
    pg_size_pretty(d.temp_bytes) AS temp_bytes_pretty,
    round(
        CASE WHEN d.total_xacts = 0 THEN 0
             ELSE d.temp_bytes::numeric / d.total_xacts
        END,
        2
    ) AS temp_bytes_per_xact,
    d.stats_reset,
    CASE
        WHEN d.temp_bytes > 5::bigint * 1024 * 1024 * 1024 THEN 'SEVERE_SPILL_PRESSURE'
        WHEN d.temp_bytes > 1::bigint * 1024 * 1024 * 1024 THEN 'MODERATE_SPILL_PRESSURE'
        ELSE 'LOW_SPILL_PRESSURE'
    END AS pressure_label
FROM cfg c
CROSS JOIN db d;

\if :has_pgss
SELECT
    queryid,
    calls,
    round(total_exec_time::numeric, 2) AS total_exec_time_ms,
    round(mean_exec_time::numeric, 2) AS mean_exec_time_ms,
    temp_blks_written,
    pg_size_pretty(temp_blks_written::bigint * current_setting('block_size')::int) AS temp_written_pretty,
    shared_blks_read,
    left(query, 220) AS query_snippet
FROM pg_stat_statements
WHERE temp_blks_written > 0
ORDER BY temp_blks_written DESC, total_exec_time DESC
LIMIT 60;
\else
SELECT
    'pg_stat_statements extension is not installed. Query-level spill attribution unavailable.'::text AS guidance;
\endif


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  database_name | work_mem | maintenance_work_mem | temp_file_limit | temp_files | temp_bytes_pretty | temp_bytes_per_xact | stats_reset |     pressure_label      
-- ---------------+----------+----------------------+-----------------+------------+-------------------+---------------------+-------------+-------------------------
--  pgbench_test  | 4MB      | 64MB                 | -1              |        111 | 4164 MB           |              562.62 |             | MODERATE_SPILL_PRESSURE
-- (1 row)
-- 
--        queryid        | calls | total_exec_time_ms | mean_exec_time_ms | temp_blks_written | temp_written_pretty | shared_blks_read |                                                          query_snippet                                                          
-- ----------------------+-------+--------------------+-------------------+-------------------+---------------------+------------------+---------------------------------------------------------------------------------------------------------------------------------
--   -214248046822219685 |     2 |           37841.83 |          18920.92 |             15408 | 120 MB              |          1313283 | DO $$                                                                                                                          +
--                       |       |                    |                   |                   |                     |                  | DECLARE                                                                                                                        +
--                       |       |                    |                   |                   |                     |                  |     v_schema text;                                                                                                             +
--                       |       |                    |                   |                   |                     |                  |     v_table text;                                                                                                              +
--                       |       |                    |                   |                   |                     |                  |     v_history_years int;                                                                                                       +
--                       |       |                    |                   |                   |                     |                  |     v_target_gb numeric;                                                                                                       +
--                       |       |                    |                   |                   |                     |                  |     v_payload_bytes int;                                                                                                       +
--                       |       |                    |                   |                   |                     |                  |     v_batch_rows int;                                                                                                          +
--                       |       |                    |                   |                   |                     |                  |     v_target_bytes bigint;                                                                                                     +
--                       |       |                    |                   |                   |                     |                  |     v_start_date date;                                                                                                         +
--                       |       |                    |                   |                   |                     |                  |     v_end_date date :=
--  -6127080060642381402 |    36 |           36092.24 |           1002.56 |             15408 | 120 MB              |                4 | INSERT INTO partition_lab.fact_events_10y_unpartitioned (event_date, account_id, amount, payload)                              +
--                       |       |                    |                   |                   |                     |                  |             SELECT                                                                                                             +
--                       |       |                    |                   |                   |                     |                  |                 ($1::date + ((gs - $2) % $3))::date AS event_date,                                                             +
--                       |       |                    |                   |                   |                     |                  |                 ($4 + (gs % $5))::bi
--  -8275299279783089467 |     6 |            6922.60 |           1153.77 |              9640 | 75 MB               |               17 | CREATE INDEX IF NOT EXISTS idx_v2_order_fact_search_lower                                                                      +
--                       |       |                    |                   |                   |                     |                  |     ON migration_v2_lab.order_fact (lower(search_text))
--  -8708022775858244193 |     6 |             275.67 |             45.95 |              4410 | 34 MB               |                0 | CREATE INDEX IF NOT EXISTS idx_v2_order_fact_filter_key                                                                        +
--                       |       |                    |                   |                   |                     |                  |     ON migration_v2_lab.order_fact (filter_key)
--   1114623876772974445 |     6 |             220.61 |             36.77 |              3675 | 29 MB               |             1907 | CREATE INDEX IF NOT EXISTS idx_v2_child_events_account_id                                                                      +
--                       |       |                    |                   |                   |                     |                  |     ON migration_v2_lab.child_events (account_id)
--    847396262454713343 |     6 |            4926.30 |            821.05 |              3078 | 24 MB               |                6 | INSERT INTO migration_v2_lab.order_fact (account_id, filter_key, search_text, order_amount)                                    +
--                       |       |                    |                   |                   |                     |                  | SELECT                                                                                                                         +
--                       |       |                    |                   |                   |                     |                  |     ($1 + (random() * $2)::int)::bigint,                                                                                       +
--                       |       |                    |                   |                   |                     |                  |     ($3 + (random() * $4)::int),                                                                                               +
--                       |       |                    |                   |                   |                     |                  |     CASE WHEN gs % $5 = $6 THEN $7 || gs ELSE $
--  -6652883949691502391 |     6 |            6777.13 |           1129.52 |              2568 | 20 MB               |                6 | INSERT INTO migration_v2_lab.child_events (account_id, event_type, amount)                                                     +
--                       |       |                    |                   |                   |                     |                  | SELECT                                                                                                                         +
--                       |       |                    |                   |                   |                     |                  |     ($1 + (random() * $2)::int)::bigint,                                                                                       +
--                       |       |                    |                   |                   |                     |                  |     CASE WHEN gs % $3 = $4 THEN $5 WHEN gs % $6 = $7 THEN $8 ELSE $9 END,                                                      +
--                       |       |                    |                   |                   |                     |                  |     round((random() * $
--  -5065162101678021495 |     9 |            4116.56 |            457.40 |              1848 | 14 MB               |                9 | INSERT INTO migration_v2_lab.stale_stats_table (payload)                                                                       +
--                       |       |                    |                   |                   |                     |                  | SELECT md5(random()::text) || md5((random() * $1)::text)                                                                       +
--                       |       |                    |                   |                   |                     |                  | FROM generate_series($2, $3)
--   4667898782383165389 |     6 |            1701.86 |            283.64 |              1236 | 9888 kB             |                6 | INSERT INTO migration_v2_lab.sales_catalog (item_ref, item_type, price)                                                        +
--                       |       |                    |                   |                   |                     |                  | SELECT                                                                                                                         +
--                       |       |                    |                   |                   |                     |                  |     $1 || gs,                                                                                                                  +
--                       |       |                    |                   |                   |                     |                  |     CASE WHEN gs % $2 = $3 THEN $4 WHEN gs % $5 = $6 THEN $7 WHEN gs % $8 = $9 THEN $10 WHEN gs % $11 = $12 THEN $13 ELSE $14 E
--   1579180460630060410 |     6 |            1261.81 |            210.30 |              1236 | 9888 kB             |                6 | INSERT INTO migration_v2_lab.amount_mapping_risk (source_numeric, target_int4_model)                                           +
--                       |       |                    |                   |                   |                     |                  | SELECT                                                                                                                         +
--                       |       |                    |                   |                   |                     |                  |     CASE                                                                                                                       +
--                       |       |                    |                   |                   |                     |                  |         WHEN gs % $1 = $2 THEN $3 + gs                                                                                         +
--                       |       |                    |                   |                   |                     |                  |         WHEN gs % $4 = $5 THEN $6 - gs                                                                                         +
--                       |       |                    |                   |                   |                     |                  |         ELSE gs::numeric                                                                                                       +
--                       |       |                    |                   |                   |                     |                  |     END,                                                                                                                       +
--                       |       |                    |                   |                   |                     |                  |     $7                                                                                                                         +
--                       |       |                    |                   |                   |                     |                  | 
--   7127220720807722591 |     4 |            2175.88 |            543.97 |               824 | 6592 kB             |                4 | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)                                                           +
--                       |       |                    |                   |                   |                     |                  | SELECT                                                                                                                         +
--                       |       |                    |                   |                   |                     |                  |     ($1 + (random() * $2)::int)::bigint,                                                                                       +
--                       |       |                    |                   |                   |                     |                  |     round((random() * $3)::numeric, $4)                                                                                        +
--                       |       |                    |                   |                   |                     |                  | FROM generate_series($5, $6)
--   7127220720807722591 |     3 |            1649.31 |            549.77 |               618 | 4944 kB             |                3 | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)                                                           +
--                       |       |                    |                   |                   |                     |                  | SELECT                                                                                                                         +
--                       |       |                    |                   |                   |                     |                  |     ($1 + (random() * $2)::int)::bigint,                                                                                       +
--                       |       |                    |                   |                   |                     |                  |     round((random() * $3)::numeric, $4)                                                                                        +
--                       |       |                    |                   |                   |                     |                  | FROM generate_series($5, $6)
--   7127220720807722591 |     3 |            1636.26 |            545.42 |               618 | 4944 kB             |                3 | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)                                                           +
--                       |       |                    |                   |                   |                     |                  | SELECT                                                                                                                         +
--                       |       |                    |                   |                   |                     |                  |     ($1 + (random() * $2)::int)::bigint,                                                                                       +
--                       |       |                    |                   |                   |                     |                  |     round((random() * $3)::numeric, $4)                                                                                        +
--                       |       |                    |                   |                   |                     |                  | FROM generate_series($5, $6)
-- (13 rows)
-- 
-- SAMPLE_OUTPUT_END
