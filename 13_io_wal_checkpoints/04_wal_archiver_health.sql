/*
PostgreSQL DBA Script: WAL Archiver Health
Purpose: Check WAL archiver success/failure and recency.
Area: I/O, WAL, and Checkpoints
Usage: Run on primary where archiving is configured.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  archived_count | last_archived_wal | last_archived_time | failed_count | last_failed_wal | last_failed_time |          stats_reset          
-- ----------------+-------------------+--------------------+--------------+-----------------+------------------+-------------------------------
--               0 |                   |                    |            0 |                 |                  | 2026-01-31 20:40:48.109778-05
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
