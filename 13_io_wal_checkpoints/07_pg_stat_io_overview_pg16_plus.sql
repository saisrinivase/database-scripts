/*
PostgreSQL DBA Script: Pg Stat IO Overview Pg16 Plus
Purpose: Provide consolidated I/O stats from pg_stat_io view.
Area: I/O, WAL, and Checkpoints
Usage: PostgreSQL 16+ only.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT (current_setting('server_version_num')::int >= 160000) AS has_pg_stat_io \gset

\if :has_pg_stat_io
SELECT
    backend_type,
    object,
    context,
    reads,
    read_time,
    writes,
    write_time,
    writebacks,
    writeback_time,
    extends,
    extend_time,
    fsyncs,
    fsync_time
FROM pg_stat_io
ORDER BY read_time DESC NULLS LAST, write_time DESC NULLS LAST;
\else
SELECT
    current_setting('server_version_num') AS server_version_num,
    'pg_stat_io is available from PostgreSQL 16+. Upgrade server or skip this script on PG15.' AS note;
\endif




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--     backend_type     |    object     |  context  |  reads   | read_time | writes  | write_time | writebacks | writeback_time | extends | extend_time | fsyncs | fsync_time 
-- ---------------------+---------------+-----------+----------+-----------+---------+------------+------------+----------------+---------+-------------+--------+------------
--  io worker           | relation      | init      |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
--  client backend      | relation      | bulkwrite |        0 |         0 | 3722888 |          0 |          0 |              0 |   57658 |           0 |        |           
--  client backend      | relation      | init      |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
--  client backend      | relation      | normal    | 10692731 |         0 | 7875962 |          0 |          0 |              0 |  132837 |           0 |      0 |          0
--  client backend      | relation      | vacuum    |    88335 |         0 |   11862 |          0 |          0 |              0 |       0 |           0 |        |           
--  client backend      | temp relation | normal    |        0 |         0 |       0 |          0 |            |                |      53 |           0 |        |           
--  slotsync worker     | temp relation | normal    |        0 |         0 |       0 |          0 |            |                |       0 |           0 |        |           
--  slotsync worker     | wal           | normal    |        0 |         0 |       0 |          0 |            |                |         |             |      0 |          0
--  standalone backend  | relation      | bulkread  |        0 |         0 |       0 |          0 |          0 |              0 |         |             |        |           
--  standalone backend  | relation      | bulkwrite |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
--  standalone backend  | relation      | init      |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
--  standalone backend  | relation      | normal    |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
--  standalone backend  | relation      | vacuum    |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
--  standalone backend  | wal           | normal    |        0 |         0 |       0 |          0 |            |                |         |             |      0 |          0
--  checkpointer        | wal           | normal    |        0 |         0 |     127 |          0 |            |                |         |             |      0 |          0
--  io worker           | relation      | bulkread  |        0 |         0 |       0 |          0 |          0 |              0 |         |             |        |           
--  io worker           | relation      | bulkwrite |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
--  client backend      | relation      | bulkread  |   119076 |         0 |    1039 |          0 |          0 |              0 |         |             |        |           
--  io worker           | relation      | normal    |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
--  io worker           | relation      | vacuum    |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
--  io worker           | temp relation | normal    |        0 |         0 |       0 |          0 |            |                |       0 |           0 |        |           
--  io worker           | wal           | normal    |        0 |         0 |       0 |          0 |            |                |         |             |      0 |          0
--  startup             | relation      | bulkread  |        0 |         0 |       0 |          0 |          0 |              0 |         |             |        |           
--  startup             | relation      | bulkwrite |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
--  startup             | relation      | init      |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
--  startup             | relation      | normal    |       60 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
--  startup             | relation      | vacuum    |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
--  startup             | wal           | normal    |       35 |         0 |       0 |          0 |            |                |         |             |      0 |          0
--  walsummarizer       | wal           | normal    |        0 |         0 |       0 |          0 |            |                |         |             |      0 |          0
--  client backend      | wal           | normal    |        0 |         0 | 3845365 |          0 |            |                |         |             |      0 |          0
--  autovacuum launcher | relation      | bulkread  |        0 |         0 |       0 |          0 |          0 |              0 |         |             |        |           
--  autovacuum launcher | relation      | init      |        0 |         0 |       0 |          0 |          0 |              0 |         |             |      0 |          0
--  autovacuum launcher | relation      | normal    |       44 |         0 |      32 |          0 |          0 |              0 |         |             |      0 |          0
--  autovacuum worker   | relation      | bulkread  |        0 |         0 |       0 |          0 |          0 |              0 |         |             |        |           
--  autovacuum worker   | relation      | init      |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
--  autovacuum worker   | relation      | normal    |     4513 |         0 |    2029 |          0 |          0 |              0 |     106 |           0 |      0 |          0
--  autovacuum worker   | relation      | vacuum    |    15094 |         0 |   42462 |          0 |          0 |              0 |       0 |           0 |        |           
--  background worker   | relation      | bulkread  |   115415 |         0 |       0 |          0 |          0 |              0 |         |             |        |           
--  background worker   | relation      | bulkwrite |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
--  background worker   | relation      | init      |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
--  background worker   | relation      | normal    |      165 |         0 |     574 |          0 |          0 |              0 |       0 |           0 |      0 |          0
--  background worker   | relation      | vacuum    |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
--  background worker   | temp relation | normal    |        0 |         0 |       0 |          0 |            |                |       0 |           0 |        |           
--  background worker   | wal           | normal    |        0 |         0 |       0 |          0 |            |                |         |             |      0 |          0
--  walsender           | relation      | bulkread  |        0 |         0 |       0 |          0 |          0 |              0 |         |             |        |           
--  walsender           | relation      | bulkwrite |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
--  walsender           | relation      | init      |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
--  walsender           | relation      | normal    |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
--  walsender           | relation      | vacuum    |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
--  walsender           | temp relation | normal    |        0 |         0 |       0 |          0 |            |                |       0 |           0 |        |           
--  walsender           | wal           | normal    |        0 |         0 |       0 |          0 |            |                |         |             |      0 |          0
--  slotsync worker     | relation      | bulkread  |        0 |         0 |       0 |          0 |          0 |              0 |         |             |        |           
--  slotsync worker     | relation      | bulkwrite |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
--  slotsync worker     | relation      | init      |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
--  slotsync worker     | relation      | normal    |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |      0 |          0
--  slotsync worker     | relation      | vacuum    |        0 |         0 |       0 |          0 |          0 |              0 |       0 |           0 |        |           
--  client backend      | wal           | init      |          |           |      61 |          0 |            |                |         |             |     61 |          0
--  walreceiver         | wal           | normal    |          |           |       0 |          0 |            |                |         |             |      0 |          0
--  walsummarizer       | wal           | init      |          |           |       0 |          0 |            |                |         |             |      0 |          0
--  standalone backend  | wal           | init      |          |           |       0 |          0 |            |                |         |             |      0 |          0
--  walwriter           | wal           | normal    |          |           |    3670 |          0 |            |                |         |             |      0 |          0
--  autovacuum launcher | wal           | init      |          |           |       0 |          0 |            |                |         |             |      0 |          0
--  autovacuum launcher | wal           | normal    |          |           |       0 |          0 |            |                |         |             |      0 |          0
--  walsender           | wal           | init      |          |           |       0 |          0 |            |                |         |             |      0 |          0
--  background writer   | relation      | init      |          |           |       0 |          0 |          0 |              0 |         |             |      0 |          0
--  background writer   | relation      | normal    |          |           |  277435 |          0 |          0 |              0 |         |             |      0 |          0
--  background writer   | wal           | init      |          |           |       0 |          0 |            |                |         |             |      0 |          0
--  autovacuum worker   | wal           | init      |          |           |       0 |          0 |            |                |         |             |      0 |          0
--  autovacuum worker   | wal           | normal    |          |           |     179 |          0 |            |                |         |             |      0 |          0
--  background writer   | wal           | normal    |          |           |       2 |          0 |            |                |         |             |      0 |          0
--  checkpointer        | relation      | init      |          |           |       0 |          0 |          0 |              0 |         |             |      0 |          0
--  checkpointer        | relation      | normal    |          |           |   68013 |          0 |          0 |              0 |         |             |   3054 |          0
--  checkpointer        | wal           | init      |          |           |       2 |          0 |            |                |         |             |      2 |          0
--  slotsync worker     | wal           | init      |          |           |       0 |          0 |            |                |         |             |      0 |          0
--  io worker           | wal           | init      |          |           |       0 |          0 |            |                |         |             |      0 |          0
--  background worker   | wal           | init      |          |           |       0 |          0 |            |                |         |             |      0 |          0
--  startup             | wal           | init      |          |           |       0 |          0 |            |                |         |             |      0 |          0
--  walwriter           | wal           | init      |          |           |       0 |          0 |            |                |         |             |      0 |          0
--  walreceiver         | wal           | init      |          |           |       0 |          0 |            |                |         |             |      0 |          0
-- (79 rows)
-- 
-- SAMPLE_OUTPUT_END
