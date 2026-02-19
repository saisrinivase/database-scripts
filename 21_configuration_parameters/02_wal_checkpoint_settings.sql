/*
Purpose: Show WAL and checkpoint settings that affect write latency and recovery behavior.
Area: Configuration Parameters
Usage: Review together with checkpoint and WAL pressure scripts.
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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

             name             | setting | unit |       source       
------------------------------+---------+------+--------------------
 checkpoint_completion_target | 0.9     |      | default
 checkpoint_timeout           | 300     | s    | default
 max_wal_size                 | 1024    | MB   | configuration file
 min_wal_size                 | 80      | MB   | configuration file
 synchronous_commit           | on      |      | default
 wal_buffers                  | 512     | 8kB  | default
 wal_compression              | off     |      | default
 wal_level                    | replica |      | default
 wal_writer_delay             | 200     | ms   | default
 wal_writer_flush_after       | 128     | 8kB  | default
(10 rows)


SAMPLE_OUTPUT_END */
