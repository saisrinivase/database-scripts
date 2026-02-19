/*
Purpose: Profile read/write, temp, and transaction behavior by database.
Area: I/O, WAL, and Checkpoints
Usage: Compare across databases to identify noisy tenants.
*/
SELECT
    datname AS database_name,
    numbackends,
    xact_commit,
    xact_rollback,
    blks_read,
    blks_hit,
    tup_returned,
    tup_fetched,
    tup_inserted,
    tup_updated,
    tup_deleted,
    temp_files,
    temp_bytes,
    deadlocks,
    blk_read_time,
    blk_write_time,
    stats_reset
FROM pg_stat_database
WHERE datname NOT IN ('template0', 'template1')
ORDER BY blks_read DESC, temp_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--            database_name           | numbackends | xact_commit | xact_rollback | blks_read | blks_hit  | tup_returned | tup_fetched | tup_inserted | tup_updated | tup_deleted | temp_files | temp_bytes | deadlocks | blk_read_time | blk_write_time | stats_reset 
-- -----------------------------------+-------------+-------------+---------------+-----------+-----------+--------------+-------------+--------------+-------------+-------------+------------+------------+-----------+---------------+----------------+-------------
--  pgbench_test                      |           1 |     5350826 |            18 |  14236570 | 173869064 |    242014342 |    23119047 |    211097266 |    16685882 |      209464 |         51 | 4161232384 |         0 |             0 |              0 | 
--  hypopg_lab                        |           0 |        8607 |             0 |      4115 |    327204 |      3893614 |       71675 |          370 |          59 |         275 |          0 |          0 |         0 |             0 |              0 | 
--  postgres                          |           0 |        9767 |            12 |      2113 |   5589160 |      5052564 |      580972 |       830654 |         475 |       41201 |          3 |    5040000 |         0 |             0 |              0 | 
--  appdb                             |           0 |        9299 |             9 |      1679 |    336614 |      3830509 |       78262 |          417 |          55 |         320 |          0 |          0 |         0 |             0 |              0 | 
--  perf_test                         |           0 |        8615 |             2 |      1244 |    327627 |      4812662 |       72170 |          369 |          29 |         274 |          0 |          0 |         0 |             0 |              0 | 
--  script_validation_20260218_172749 |           0 |        2656 |            24 |       518 |   7833029 |      2961546 |     1194783 |      1107322 |         620 |       54091 |          4 |    6720000 |         0 |             0 |              0 | 
-- (6 rows)
-- 
-- SAMPLE_OUTPUT_END

