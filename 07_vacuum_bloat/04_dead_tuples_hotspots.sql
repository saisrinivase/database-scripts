/*
PostgreSQL DBA Script: Dead Tuples Hotspots
Purpose: Rank tables by dead tuple count and dead tuple percentage.
Area: Vacuum and Bloat
Usage: Supports targeting manual VACUUM or autovacuum tuning.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    n_live_tup,
    n_dead_tup,
    round(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_tuple_pct,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name |    table_name    | n_live_tup | n_dead_tup | dead_tuple_pct | total_size 
-- -------------+------------------+------------+------------+----------------+------------
--  public      | pgbench_accounts |  200000029 |    4232485 |           2.07 | 30 GB
--  public      | pgbench_branches |       2000 |         81 |           3.89 | 7048 kB
-- (2 rows)
-- 
-- SAMPLE_OUTPUT_END
