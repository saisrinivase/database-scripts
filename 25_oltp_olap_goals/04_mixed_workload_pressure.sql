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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

           database_name           | xact_commit | xact_rollback | blks_read | blks_hit  | temp_files | temp_bytes | deadlocks | blk_read_time | blk_write_time | numbackends | recommendation 
-----------------------------------+-------------+---------------+-----------+-----------+------------+------------+-----------+---------------+----------------+-------------+----------------
 pgbench_test                      |     5349094 |             2 |  14208247 | 141643215 |          6 | 4008443904 |         0 |             0 |              0 |           0 | Normal/Mild
 postgres                          |        9327 |             8 |      1605 |   5554276 |          3 |    5040000 |         0 |             0 |              0 |           1 | Normal/Mild
 script_validation_20260218_172749 |        2287 |            24 |       372 |   6094112 |          3 |    5040000 |         0 |             0 |              0 |           1 | Normal/Mild
 hypopg_lab                        |        8365 |             0 |      4016 |    318470 |          0 |          0 |         0 |             0 |              0 |           0 | Normal/Mild
 appdb                             |        9044 |             9 |      1541 |    327669 |          0 |          0 |         0 |             0 |              0 |           2 | Normal/Mild
 perf_test                         |        8375 |             2 |      1103 |    318136 |          0 |          0 |         0 |             0 |              0 |           0 | Normal/Mild
(6 rows)


SAMPLE_OUTPUT_END */
