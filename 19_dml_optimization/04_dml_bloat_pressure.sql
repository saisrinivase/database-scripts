/*
Purpose: Show write-heavy tables with dead tuple pressure (bloat risk).
Area: Optimizing Data Modification
Usage: Candidate list for VACUUM tuning and batch rewrite strategies.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    n_live_tup,
    n_dead_tup,
    round(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_tuple_pct,
    (n_tup_ins + n_tup_upd + n_tup_del) AS total_writes,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY dead_tuple_pct DESC NULLS LAST, total_writes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name |    table_name    | n_live_tup | n_dead_tup | dead_tuple_pct | total_writes | total_size 
-- -------------+------------------+------------+------------+----------------+--------------+------------
--  public      | pgbench_branches |       2000 |         81 |           3.89 |      5334823 | 7048 kB
--  public      | pgbench_accounts |  200000029 |    4232485 |           2.07 |    205332823 | 30 GB
-- (2 rows)
-- 
-- SAMPLE_OUTPUT_END
