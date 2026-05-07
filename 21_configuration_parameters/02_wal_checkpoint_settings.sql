/*
PostgreSQL DBA Script: WAL Checkpoint Settings
Purpose: Show WAL and checkpoint settings that affect write latency and recovery behavior.
Area: Configuration Parameters
Usage: Review together with checkpoint and WAL pressure scripts.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    name,
    setting,
    unit,
    source
FROM pg_settings
WHERE name IN (
    'wal_level',
    'wal_compression',
    'wal_buffers',
    'wal_writer_delay',
    'wal_writer_flush_after',
    'checkpoint_timeout',
    'checkpoint_completion_target',
    'max_wal_size',
    'min_wal_size',
    'synchronous_commit'
)
ORDER BY name;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--              name             | setting | unit |       source       
-- ------------------------------+---------+------+--------------------
--  checkpoint_completion_target | 0.9     |      | default
--  checkpoint_timeout           | 300     | s    | default
--  max_wal_size                 | 1024    | MB   | configuration file
--  min_wal_size                 | 80      | MB   | configuration file
--  synchronous_commit           | on      |      | default
--  wal_buffers                  | 512     | 8kB  | default
--  wal_compression              | off     |      | default
--  wal_level                    | replica |      | default
--  wal_writer_delay             | 200     | ms   | default
--  wal_writer_flush_after       | 128     | 8kB  | default
-- (10 rows)
-- 
-- SAMPLE_OUTPUT_END
