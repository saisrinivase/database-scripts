/*
Purpose: Profile I/O latency per database to detect storage-level bottlenecks.
Area: Physical and Cloud Diagnostics
Usage: Compare with historical baselines and provider metrics.
*/
SELECT
    datname AS database_name,
    blks_read,
    blks_hit,
    blk_read_time,
    blk_write_time,
    CASE WHEN blks_read = 0 THEN NULL ELSE blk_read_time / blks_read END AS ms_per_block_read,
    CASE WHEN (xact_commit + xact_rollback) = 0 THEN NULL ELSE blk_write_time / (xact_commit + xact_rollback) END AS write_time_per_txn
FROM pg_stat_database
WHERE datname NOT IN ('template0', 'template1')
ORDER BY ms_per_block_read DESC NULLS LAST, blk_read_time DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--            database_name           | blks_read | blks_hit  | blk_read_time | blk_write_time | ms_per_block_read | write_time_per_txn 
-- -----------------------------------+-----------+-----------+---------------+----------------+-------------------+--------------------
--  postgres                          |      2113 |   5589160 |             0 |              0 |                 0 |                  0
--  perf_test                         |      1244 |    327627 |             0 |              0 |                 0 |                  0
--  appdb                             |      1679 |    336614 |             0 |              0 |                 0 |                  0
--  hypopg_lab                        |      4115 |    327204 |             0 |              0 |                 0 |                  0
--  pgbench_test                      |  14236640 | 173923446 |             0 |              0 |                 0 |                  0
--  script_validation_20260218_172749 |       518 |   7833029 |             0 |              0 |                 0 |                  0
-- (6 rows)
-- 
-- SAMPLE_OUTPUT_END
