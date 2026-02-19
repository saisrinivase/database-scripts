/*
Purpose: Rank databases by temp file usage (spill pressure indicator).
Area: I/O, WAL, and Checkpoints
Usage: Tune query patterns and memory settings for top consumers.
*/
SELECT
    datname AS database_name,
    temp_files,
    temp_bytes,
    pg_size_pretty(temp_bytes) AS temp_pretty,
    xact_commit,
    xact_rollback,
    stats_reset
FROM pg_stat_database
WHERE datname NOT IN ('template0', 'template1')
ORDER BY temp_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--            database_name           | temp_files | temp_bytes | temp_pretty | xact_commit | xact_rollback | stats_reset 
-- -----------------------------------+------------+------------+-------------+-------------+---------------+-------------
--  pgbench_test                      |         51 | 4161232384 | 3968 MB     |     5350837 |            18 | 
--  script_validation_20260218_172749 |          4 |    6720000 | 6563 kB     |        2656 |            24 | 
--  postgres                          |          3 |    5040000 | 4922 kB     |        9767 |            12 | 
--  perf_test                         |          0 |          0 | 0 bytes     |        8615 |             2 | 
--  appdb                             |          0 |          0 | 0 bytes     |        9299 |             9 | 
--  hypopg_lab                        |          0 |          0 | 0 bytes     |        8607 |             0 | 
-- (6 rows)
-- 
-- SAMPLE_OUTPUT_END
