/*
Purpose: Summarize mixed-workload pressure indicators by database.
Area: Optimization Goals (OLTP vs OLAP)
Usage: Useful for deciding workload isolation strategy.
*/
SELECT
    d.datname AS database_name,
    d.xact_commit,
    d.xact_rollback,
    d.blks_read,
    d.blks_hit,
    d.temp_files,
    d.temp_bytes,
    d.deadlocks,
    d.blk_read_time,
    d.blk_write_time,
    d.numbackends,
    CASE
        WHEN d.xact_commit > 0 AND d.temp_bytes > 0 AND d.blks_read > d.blks_hit / 4 THEN 'Mixed workload pressure'
        ELSE 'Normal/Mild'
    END AS recommendation
FROM pg_stat_database d
WHERE d.datname NOT IN ('template0', 'template1')
ORDER BY d.temp_bytes DESC, d.blks_read DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--            database_name           | xact_commit | xact_rollback | blks_read | blks_hit  | temp_files | temp_bytes | deadlocks | blk_read_time | blk_write_time | numbackends | recommendation 
-- -----------------------------------+-------------+---------------+-----------+-----------+------------+------------+-----------+---------------+----------------+-------------+----------------
--  pgbench_test                      |     5350957 |            18 |  14236640 | 173922925 |         51 | 4161232384 |         0 |             0 |              0 |           1 | Normal/Mild
--  script_validation_20260218_172749 |        2656 |            24 |       518 |   7833029 |          4 |    6720000 |         0 |             0 |              0 |           0 | Normal/Mild
--  postgres                          |        9767 |            12 |      2113 |   5589160 |          3 |    5040000 |         0 |             0 |              0 |           0 | Normal/Mild
--  hypopg_lab                        |        8607 |             0 |      4115 |    327204 |          0 |          0 |         0 |             0 |              0 |           0 | Normal/Mild
--  appdb                             |        9299 |             9 |      1679 |    336614 |          0 |          0 |         0 |             0 |              0 |           0 | Normal/Mild
--  perf_test                         |        8615 |             2 |      1244 |    327627 |          0 |          0 |         0 |             0 |              0 |           0 | Normal/Mild
-- (6 rows)
-- 
-- SAMPLE_OUTPUT_END
