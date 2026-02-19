/*
Purpose: Highlight table bloat pressure using dead tuple and scan behavior proxies.
Area: Object Inventory and Health
Usage: Prioritize VACUUM/rewrite/index strategy on high dead-tuple large relations.
*/
WITH table_stats AS (
    SELECT
        s.schemaname AS schema_name,
        s.relname AS table_name,
        s.relid,
        s.n_live_tup,
        s.n_dead_tup,
        s.seq_scan,
        s.idx_scan,
        s.vacuum_count,
        s.autovacuum_count,
        s.last_vacuum,
        s.last_autovacuum,
        pg_total_relation_size(s.relid) AS total_bytes,
        CASE
            WHEN (s.n_live_tup + s.n_dead_tup) > 0
                THEN round((100.0 * s.n_dead_tup / (s.n_live_tup + s.n_dead_tup))::numeric, 2)
            ELSE 0::numeric
        END AS dead_tuple_pct
    FROM pg_stat_user_tables s
)
SELECT
    schema_name,
    table_name,
    pg_size_pretty(total_bytes) AS total_size,
    n_live_tup,
    n_dead_tup,
    dead_tuple_pct,
    seq_scan,
    idx_scan,
    vacuum_count,
    autovacuum_count,
    last_vacuum,
    last_autovacuum,
    CASE
        WHEN dead_tuple_pct >= 25 THEN 'HIGH_BLOAT_PRESSURE'
        WHEN dead_tuple_pct >= 10 THEN 'MEDIUM_BLOAT_PRESSURE'
        ELSE 'LOW_BLOAT_PRESSURE'
    END AS bloat_flag
FROM table_stats
WHERE total_bytes >= 64::bigint * 1024 * 1024
ORDER BY dead_tuple_pct DESC, total_bytes DESC, schema_name, table_name;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 schema_name |    table_name    | total_size | n_live_tup | n_dead_tup | dead_tuple_pct | seq_scan | idx_scan | vacuum_count | autovacuum_count |          last_vacuum          |        last_autovacuum        |     bloat_flag     
-------------+------------------+------------+------------+------------+----------------+----------+----------+--------------+------------------+-------------------------------+-------------------------------+--------------------
 public      | pgbench_accounts | 30 GB      |  200000029 |    4232485 |           2.07 |        2 | 10665646 |            1 |                0 | 2026-01-31 21:17:24.785585-05 |                               | LOW_BLOAT_PRESSURE
 public      | pgbench_history  | 270 MB     |    5331130 |          0 |           0.00 |        0 |          |            1 |                6 | 2026-01-31 21:17:26.345526-05 | 2026-01-31 21:47:10.021717-05 | LOW_BLOAT_PRESSURE
(2 rows)


SAMPLE_OUTPUT_END */
