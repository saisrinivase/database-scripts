/*
Purpose: Check WAL archiver success/failure and recency.
Area: I/O, WAL, and Checkpoints
Usage: Run on primary where archiving is configured.
*/
SELECT
    archived_count,
    last_archived_wal,
    last_archived_time,
    failed_count,
    last_failed_wal,
    last_failed_time,
    stats_reset
FROM pg_stat_archiver;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 archived_count | last_archived_wal | last_archived_time | failed_count | last_failed_wal | last_failed_time |          stats_reset          
----------------+-------------------+--------------------+--------------+-----------------+------------------+-------------------------------
              0 |                   |                    |            0 |                 |                  | 2026-01-31 20:40:48.109778-05
(1 row)


SAMPLE_OUTPUT_END */
