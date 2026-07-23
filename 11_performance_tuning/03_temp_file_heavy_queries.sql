/*
PostgreSQL DBA Script: Temp File Heavy Queries
Purpose: Detect statements causing heavy temp file writes (sort/hash spill candidates).
Area: Performance Tuning
Usage: Requires pg_stat_statements; review work_mem and execution plans.
       Optional filter:
       SELECT set_config('pgdiag.min_temp_pct','40',false); -- show only SQL >= 40% of temp write load
       -- Optional timestamp placeholders when using your own pg_stat_statements snapshot table:
       -- AND snapshot_ts >= timestamp '2026-05-10 09:00:00'
       -- AND snapshot_ts <  timestamp '2026-05-10 10:00:00'
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH params AS (
    SELECT coalesce(nullif(current_setting('pgdiag.min_temp_pct', true), '')::numeric, 0) AS min_temp_pct
),
base AS (
    SELECT *
    FROM pg_stat_statements
    WHERE temp_blks_written > 0
),
totals AS (
    SELECT sum(temp_blks_written) AS all_temp_blks_written
    FROM base
)
SELECT
    queryid,
    calls,
    temp_blks_read,
    temp_blks_written,
    round(100.0 * temp_blks_written / NULLIF(t.all_temp_blks_written, 0), 2) AS pct_temp_write_load,
    (temp_blks_written * current_setting('block_size')::bigint) AS temp_bytes_written,
    pg_size_pretty((temp_blks_written * current_setting('block_size')::bigint)::bigint) AS temp_written_pretty,
    mean_exec_time,
    regexp_replace(query, '\s+', ' ', 'g') AS query_snippet
FROM base
CROSS JOIN totals t
WHERE round(100.0 * temp_blks_written / NULLIF(t.all_temp_blks_written, 0), 2) >= (SELECT min_temp_pct FROM params)
ORDER BY temp_bytes_written DESC
LIMIT 10;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--        queryid        | calls | temp_blks_read | temp_blks_written | temp_bytes_written | temp_written_pretty |  mean_exec_time   |                                                           query_snippet                                                            
-- ----------------------+-------+----------------+-------------------+--------------------+---------------------+-------------------+------------------------------------------------------------------------------------------------------------------------------------
--  -8275299279783089467 |     4 |           6434 |              6426 |           52641792 | 50 MB               |      1158.2690625 | CREATE INDEX IF NOT EXISTS idx_v2_order_fact_search_lower                                                                         +
--                       |       |                |                   |                    |                     |                   |     ON migration_v2_lab.order_fact (lower(search_text))
--  -8708022775858244193 |     4 |           2948 |              2940 |           24084480 | 23 MB               | 45.90175000000001 | CREATE INDEX IF NOT EXISTS idx_v2_order_fact_filter_key                                                                           +
--                       |       |                |                   |                    |                     |                   |     ON migration_v2_lab.order_fact (filter_key)
--   1114623876772974445 |     4 |           2457 |              2449 |           20062208 | 19 MB               |         36.545052 | CREATE INDEX IF NOT EXISTS idx_v2_child_events_account_id                                                                         +
--                       |       |                |                   |                    |                     |                   |     ON migration_v2_lab.child_events (account_id)
--    847396262454713343 |     4 |           2052 |              2052 |           16809984 | 16 MB               |       872.3010415 | INSERT INTO migration_v2_lab.order_fact (account_id, filter_key, search_text, order_amount)                                       +
--                       |       |                |                   |                    |                     |                   | SELECT                                                                                                                            +
--                       |       |                |                   |                    |                     |                   |     ($1 + (random() * $2)::int)::bigint,                                                                                          +
--                       |       |                |                   |                    |                     |                   |     ($3 + (random() * $4)::int),                                                                                                  +
--                       |       |                |                   |                    |                     |                   |     CASE WHEN gs % $5 = $6 THEN $7 || gs ELSE $8 || gs END,                                                                       +
--                       |       |                |                   |                    |                     |                   |     round(($9 + random() * $10)::numeric, $11)                                                                                    +
--                       |       |                |                   |                    |                     |                   | FROM generate_series($12, $13) AS gs
--  -6652883949691502391 |     4 |           1712 |              1712 |           14024704 | 13 MB               |     1162.38363525 | INSERT INTO migration_v2_lab.child_events (account_id, event_type, amount)                                                        +
--                       |       |                |                   |                    |                     |                   | SELECT                                                                                                                            +
--                       |       |                |                   |                    |                     |                   |     ($1 + (random() * $2)::int)::bigint,                                                                                          +
--                       |       |                |                   |                    |                     |                   |     CASE WHEN gs % $3 = $4 THEN $5 WHEN gs % $6 = $7 THEN $8 ELSE $9 END,                                                         +
--                       |       |                |                   |                    |                     |                   |     round((random() * $10)::numeric, $11)                                                                                         +
--                       |       |                |                   |                    |                     |                   | FROM generate_series($12, $13) AS gs
--  -5065162101678021495 |     5 |           1232 |              1232 |           10092544 | 9856 kB             |        536.963942 | INSERT INTO migration_v2_lab.stale_stats_table (payload)                                                                          +
--                       |       |                |                   |                    |                     |                   | SELECT md5(random()::text) || md5((random() * $1)::text)                                                                          +
--                       |       |                |                   |                    |                     |                   | FROM generate_series($2, $3)
--   4667898782383165389 |     4 |            824 |               824 |            6750208 | 6592 kB             |      297.52326025 | INSERT INTO migration_v2_lab.sales_catalog (item_ref, item_type, price)                                                           +
--                       |       |                |                   |                    |                     |                   | SELECT                                                                                                                            +
--                       |       |                |                   |                    |                     |                   |     $1 || gs,                                                                                                                     +
--                       |       |                |                   |                    |                     |                   |     CASE WHEN gs % $2 = $3 THEN $4 WHEN gs % $5 = $6 THEN $7 WHEN gs % $8 = $9 THEN $10 WHEN gs % $11 = $12 THEN $13 ELSE $14 END,+
--                       |       |                |                   |                    |                     |                   |     round(($15 + random() * $16)::numeric, $17)                                                                                   +
--                       |       |                |                   |                    |                     |                   | FROM generate_series($18, $19) AS gs
--   1579180460630060410 |     4 |            824 |               824 |            6750208 | 6592 kB             |        225.950229 | INSERT INTO migration_v2_lab.amount_mapping_risk (source_numeric, target_int4_model)                                              +
--                       |       |                |                   |                    |                     |                   | SELECT                                                                                                                            +
--                       |       |                |                   |                    |                     |                   |     CASE                                                                                                                          +
--                       |       |                |                   |                    |                     |                   |         WHEN gs % $1 = $2 THEN $3 + gs                                                                                            +
--                       |       |                |                   |                    |                     |                   |         WHEN gs % $4 = $5 THEN $6 - gs                                                                                            +
--                       |       |                |                   |                    |                     |                   |         ELSE gs::numeric                                                                                                          +
--                       |       |                |                   |                    |                     |                   |     END,                                                                                                                          +
--                       |       |                |                   |                    |                     |                   |     $7                                                                                                                            +
--                       |       |                |                   |                    |                     |                   | FROM generate_series($8, $9) AS gs
--   7127220720807722591 |     4 |            824 |               824 |            6750208 | 6592 kB             |       543.9699475 | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)                                                              +
--                       |       |                |                   |                    |                     |                   | SELECT                                                                                                                            +
--                       |       |                |                   |                    |                     |                   |     ($1 + (random() * $2)::int)::bigint,                                                                                          +
--                       |       |                |                   |                    |                     |                   |     round((random() * $3)::numeric, $4)                                                                                           +
--                       |       |                |                   |                    |                     |                   | FROM generate_series($5, $6)
--   7127220720807722591 |     3 |            618 |               618 |            5062656 | 4944 kB             | 545.4183473333334 | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)                                                              +
--                       |       |                |                   |                    |                     |                   | SELECT                                                                                                                            +
--                       |       |                |                   |                    |                     |                   |     ($1 + (random() * $2)::int)::bigint,                                                                                          +
--                       |       |                |                   |                    |                     |                   |     round((random() * $3)::numeric, $4)                                                                                           +
--                       |       |                |                   |                    |                     |                   | FROM generate_series($5, $6)
--   7127220720807722591 |     1 |            206 |               206 |            1687552 | 1648 kB             |        618.777208 | INSERT INTO migration_v1_lab.child_transactions (account_id, amount)                                                              +
--                       |       |                |                   |                    |                     |                   | SELECT                                                                                                                            +
--                       |       |                |                   |                    |                     |                   |     ($1 + (random() * $2)::int)::bigint,                                                                                          +
--                       |       |                |                   |                    |                     |                   |     round((random() * $3)::numeric, $4)                                                                                           +
--                       |       |                |                   |                    |                     |                   | FROM generate_series($5, $6)
-- (11 rows)
-- 
-- SAMPLE_OUTPUT_END
