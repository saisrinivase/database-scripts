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
