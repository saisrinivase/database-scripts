/*
PostgreSQL DBA Script: PostgreSQL 18 Asynchronous IO Readiness
Purpose: Detect PostgreSQL version, asynchronous-I/O configuration, pg_stat_io pressure, and whether PostgreSQL 18 features can be evaluated.
Area: Problem Identification and Internals
Usage: Run before and during PostgreSQL 18 I/O testing; compare interval snapshots with host or cloud latency.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only. PostgreSQL 15-17 return capability guidance; pg_stat_io is available from 16 and PostgreSQL 18 adds byte counters and asynchronous I/O controls.
*/
SELECT
    current_setting('server_version') AS server_version,
    current_setting('server_version_num')::integer AS server_version_num,
    CASE
        WHEN current_setting('server_version_num')::integer >= 180000 THEN 'PG18_ASYNC_IO_AVAILABLE'
        WHEN current_setting('server_version_num')::integer >= 160000 THEN 'PG_STAT_IO_AVAILABLE_BUT_PRE_PG18'
        ELSE 'USE_PG_STAT_DATABASE_AND_PG_STATIO'
    END AS capability,
    CASE
        WHEN current_setting('server_version_num')::integer >= 180000 THEN 'Review io_method, concurrency, combine limits, I/O waits, bytes, and timing.'
        ELSE 'Use this result as upgrade-readiness guidance; do not apply PostgreSQL 18 settings.'
    END AS next_action;

SELECT
    name,
    setting,
    unit,
    context,
    source,
    pending_restart,
    CASE name
        WHEN 'io_method' THEN 'worker, io_uring, or sync method used for asynchronous-eligible I/O.'
        WHEN 'io_workers' THEN 'I/O worker count when io_method is worker.'
        WHEN 'io_max_concurrency' THEN 'Maximum simultaneous I/O operations per process.'
        WHEN 'io_combine_limit' THEN 'Requested maximum combined I/O size.'
        WHEN 'io_max_combine_limit' THEN 'Server-start ceiling for combined I/O size.'
        WHEN 'effective_io_concurrency' THEN 'Concurrent read/prefetch expectation for normal queries.'
        WHEN 'maintenance_io_concurrency' THEN 'Concurrent I/O expectation for maintenance work.'
        WHEN 'track_io_timing' THEN 'Enables I/O timing evidence with measurable overhead.'
        WHEN 'track_wal_io_timing' THEN 'Enables WAL I/O timing evidence.'
    END AS purpose
FROM pg_settings
WHERE name IN (
    'io_method',
    'io_workers',
    'io_max_concurrency',
    'io_combine_limit',
    'io_max_combine_limit',
    'effective_io_concurrency',
    'maintenance_io_concurrency',
    'track_io_timing',
    'track_wal_io_timing'
)
ORDER BY name;

CREATE TEMP TABLE IF NOT EXISTS pg_async_io_health_result (
    backend_type text,
    object_name text,
    context_name text,
    reads numeric,
    read_bytes numeric,
    read_time_ms numeric,
    writes numeric,
    write_bytes numeric,
    write_time_ms numeric,
    fsyncs numeric,
    fsync_time_ms numeric,
    diagnosis text
);

TRUNCATE pg_async_io_health_result;

DO $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_io') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO pg_async_io_health_result
            SELECT
                backend_type,
                object,
                context,
                coalesce(sum((to_jsonb(i)->>'reads')::numeric), 0),
                coalesce(sum(
                    coalesce(
                        NULLIF(to_jsonb(i)->>'read_bytes', '')::numeric,
                        NULLIF(to_jsonb(i)->>'reads', '')::numeric
                            * coalesce(NULLIF(to_jsonb(i)->>'op_bytes', '')::numeric, current_setting('block_size')::numeric)
                    )
                ), 0),
                coalesce(sum((to_jsonb(i)->>'read_time')::numeric), 0),
                coalesce(sum((to_jsonb(i)->>'writes')::numeric), 0),
                coalesce(sum(
                    coalesce(
                        NULLIF(to_jsonb(i)->>'write_bytes', '')::numeric,
                        NULLIF(to_jsonb(i)->>'writes', '')::numeric
                            * coalesce(NULLIF(to_jsonb(i)->>'op_bytes', '')::numeric, current_setting('block_size')::numeric)
                    )
                ), 0),
                coalesce(sum((to_jsonb(i)->>'write_time')::numeric), 0),
                coalesce(sum((to_jsonb(i)->>'fsyncs')::numeric), 0),
                coalesce(sum((to_jsonb(i)->>'fsync_time')::numeric), 0),
                CASE
                    WHEN coalesce(sum((to_jsonb(i)->>'read_time')::numeric), 0)
                       + coalesce(sum((to_jsonb(i)->>'write_time')::numeric), 0)
                       + coalesce(sum((to_jsonb(i)->>'fsync_time')::numeric), 0) > 0
                    THEN 'TIMING_VISIBLE_COMPARE_INTERVAL_RATE'
                    ELSE 'COUNTERS_VISIBLE_ENABLE_TIMING_IF_APPROVED'
                END
            FROM pg_stat_io i
            GROUP BY backend_type, object, context
        $sql$;
    ELSE
        INSERT INTO pg_async_io_health_result (
            backend_type, object_name, context_name, diagnosis
        )
        VALUES (
            'UNAVAILABLE', 'pg_stat_io', 'version', 'Use pg_stat_database and pg_statio views on PostgreSQL 15.'
        );
    END IF;
END $$;

SELECT *
FROM pg_async_io_health_result
ORDER BY read_time_ms DESC NULLS LAST, write_time_ms DESC NULLS LAST, read_bytes DESC NULLS LAST;

-- SAMPLE_OUTPUT_BEGIN
-- server_version | server_version_num | capability | next_action
-- name | setting | unit | context | source | pending_restart | purpose
-- backend_type | object_name | context_name | reads | read_bytes | read_time_ms | writes | write_bytes | diagnosis
-- SAMPLE_OUTPUT_END
