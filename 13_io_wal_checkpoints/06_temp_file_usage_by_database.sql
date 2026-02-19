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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

           database_name           | temp_files | temp_bytes | temp_pretty | xact_commit | xact_rollback | stats_reset 
-----------------------------------+------------+------------+-------------+-------------+---------------+-------------
 pgbench_test                      |          6 | 4008443904 | 3823 MB     |     5349094 |             2 | 
 postgres                          |          3 |    5040000 | 4922 kB     |        9327 |             8 | 
 script_validation_20260218_172749 |          3 |    5040000 | 4922 kB     |        2167 |            24 | 
 perf_test                         |          0 |          0 | 0 bytes     |        8375 |             2 | 
 appdb                             |          0 |          0 | 0 bytes     |        9044 |             9 | 
 hypopg_lab                        |          0 |          0 | 0 bytes     |        8365 |             0 | 
(6 rows)


SAMPLE_OUTPUT_END */
