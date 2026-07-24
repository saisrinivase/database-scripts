/*
PostgreSQL DBA Script: AWS Buffer Cache Read Write IOPS Deep Dive
Purpose: Diagnose BufferCacheHitRatio, ReadIOPS, WriteIOPS, read/write throughput, and latency with cache attribution and a short PostgreSQL counter-rate sample.
Area: AWS RDS and Aurora PostgreSQL
Usage: Run during the spike. The default sample is 2 seconds; change sample_seconds in the params CTE when a longer SQL-side rate is useful.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Uses temporary tables, a pg_temp function, and pg_sleep. AWS remains authoritative for physical IOPS, Aurora storage-cache tiers, and volume latency.
*/
SELECT
    datname,
    blks_read,
    blks_hit,
    round(100.0 * blks_hit / NULLIF(blks_hit + blks_read, 0), 2) AS buffer_cache_hit_pct,
    pg_size_pretty(blks_read * current_setting('block_size')::bigint) AS cumulative_database_read_bytes,
    temp_files,
    pg_size_pretty(temp_bytes) AS cumulative_temp_bytes,
    blk_read_time,
    blk_write_time,
    stats_reset,
    CASE
        WHEN blks_hit + blks_read < 10000 THEN 'LOW_SAMPLE_VOLUME'
        WHEN 100.0 * blks_hit / NULLIF(blks_hit + blks_read, 0) < 90 THEN 'REVIEW_LOW_DATABASE_CACHE_HIT_RATIO'
        WHEN 100.0 * blks_hit / NULLIF(blks_hit + blks_read, 0) < 99 THEN 'WORKLOAD_DEPENDENT_REVIEW'
        ELSE 'HIGH_CACHE_HIT_RATIO'
    END AS interpretation
FROM pg_stat_database
WHERE datname IS NOT NULL
ORDER BY blks_read DESC, datname;

SELECT
    schemaname,
    relname,
    heap_blks_read + idx_blks_read + toast_blks_read AS physical_blocks_read,
    heap_blks_hit + idx_blks_hit + toast_blks_hit AS cache_blocks_hit,
    round(
        100.0 * (heap_blks_hit + idx_blks_hit + toast_blks_hit)
        / NULLIF(
            heap_blks_read + idx_blks_read + toast_blks_read
          + heap_blks_hit + idx_blks_hit + toast_blks_hit,
            0
        ),
        2
    ) AS relation_cache_hit_pct,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_relation_size,
    CASE
        WHEN heap_blks_read + idx_blks_read + toast_blks_read >= 100000 THEN 'TOP_PHYSICAL_READ_CONTRIBUTOR'
        ELSE 'COMPARE_INTERVAL_DELTA'
    END AS diagnosis
FROM pg_statio_user_tables
ORDER BY physical_blocks_read DESC
LIMIT 100;

CREATE OR REPLACE FUNCTION pg_temp.aws_io_totals()
RETURNS TABLE (
    reads numeric,
    writes numeric,
    extends numeric,
    fsyncs numeric,
    read_bytes numeric,
    write_bytes numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_io') IS NULL THEN
        RETURN QUERY SELECT NULL::numeric, NULL::numeric, NULL::numeric, NULL::numeric, NULL::numeric, NULL::numeric;
        RETURN;
    END IF;

    RETURN QUERY EXECUTE $query$
        SELECT
            coalesce(sum(NULLIF(to_jsonb(i)->>'reads', '')::numeric), 0),
            coalesce(sum(NULLIF(to_jsonb(i)->>'writes', '')::numeric), 0),
            coalesce(sum(NULLIF(to_jsonb(i)->>'extends', '')::numeric), 0),
            coalesce(sum(NULLIF(to_jsonb(i)->>'fsyncs', '')::numeric), 0),
            coalesce(sum(coalesce(
                NULLIF(to_jsonb(i)->>'read_bytes', '')::numeric,
                NULLIF(to_jsonb(i)->>'reads', '')::numeric
                    * coalesce(NULLIF(to_jsonb(i)->>'op_bytes', '')::numeric, current_setting('block_size')::numeric)
            )), 0),
            coalesce(sum(coalesce(
                NULLIF(to_jsonb(i)->>'write_bytes', '')::numeric,
                NULLIF(to_jsonb(i)->>'writes', '')::numeric
                    * coalesce(NULLIF(to_jsonb(i)->>'op_bytes', '')::numeric, current_setting('block_size')::numeric)
            )), 0)
        FROM pg_stat_io i
    $query$;
END;
$$;

CREATE TEMP TABLE IF NOT EXISTS aws_io_rate_sample (
    sample_name text,
    captured_at timestamptz,
    database_blocks_read numeric,
    database_blocks_hit numeric,
    temp_bytes numeric,
    wal_bytes numeric,
    io_reads numeric,
    io_writes numeric,
    io_extends numeric,
    io_fsyncs numeric,
    io_read_bytes numeric,
    io_write_bytes numeric
);

TRUNCATE aws_io_rate_sample;

INSERT INTO aws_io_rate_sample
SELECT
    'start',
    clock_timestamp(),
    coalesce(sum(blks_read), 0),
    coalesce(sum(blks_hit), 0),
    coalesce(sum(temp_bytes), 0),
    (SELECT wal_bytes FROM pg_stat_wal),
    i.reads,
    i.writes,
    i.extends,
    i.fsyncs,
    i.read_bytes,
    i.write_bytes
FROM pg_stat_database
CROSS JOIN pg_temp.aws_io_totals() i
WHERE datname IS NOT NULL
GROUP BY i.reads, i.writes, i.extends, i.fsyncs, i.read_bytes, i.write_bytes;

WITH params AS (
    SELECT 2::numeric AS sample_seconds
)
SELECT pg_sleep(sample_seconds)
FROM params;

INSERT INTO aws_io_rate_sample
SELECT
    'end',
    clock_timestamp(),
    coalesce(sum(blks_read), 0),
    coalesce(sum(blks_hit), 0),
    coalesce(sum(temp_bytes), 0),
    (SELECT wal_bytes FROM pg_stat_wal),
    i.reads,
    i.writes,
    i.extends,
    i.fsyncs,
    i.read_bytes,
    i.write_bytes
FROM pg_stat_database
CROSS JOIN pg_temp.aws_io_totals() i
WHERE datname IS NOT NULL
GROUP BY i.reads, i.writes, i.extends, i.fsyncs, i.read_bytes, i.write_bytes;

WITH endpoints AS (
    SELECT
        max(captured_at) FILTER (WHERE sample_name = 'end')
          - max(captured_at) FILTER (WHERE sample_name = 'start') AS elapsed,
        max(database_blocks_read) FILTER (WHERE sample_name = 'end')
          - max(database_blocks_read) FILTER (WHERE sample_name = 'start') AS database_read_blocks,
        max(database_blocks_hit) FILTER (WHERE sample_name = 'end')
          - max(database_blocks_hit) FILTER (WHERE sample_name = 'start') AS database_hit_blocks,
        max(temp_bytes) FILTER (WHERE sample_name = 'end')
          - max(temp_bytes) FILTER (WHERE sample_name = 'start') AS temp_bytes,
        max(wal_bytes) FILTER (WHERE sample_name = 'end')
          - max(wal_bytes) FILTER (WHERE sample_name = 'start') AS wal_bytes,
        max(io_reads) FILTER (WHERE sample_name = 'end')
          - max(io_reads) FILTER (WHERE sample_name = 'start') AS io_reads,
        max(io_writes) FILTER (WHERE sample_name = 'end')
          - max(io_writes) FILTER (WHERE sample_name = 'start') AS io_writes,
        max(io_read_bytes) FILTER (WHERE sample_name = 'end')
          - max(io_read_bytes) FILTER (WHERE sample_name = 'start') AS io_read_bytes,
        max(io_write_bytes) FILTER (WHERE sample_name = 'end')
          - max(io_write_bytes) FILTER (WHERE sample_name = 'start') AS io_write_bytes
    FROM aws_io_rate_sample
),
rates AS (
    SELECT
        extract(epoch FROM elapsed)::numeric AS elapsed_seconds,
        database_read_blocks,
        database_hit_blocks,
        temp_bytes,
        wal_bytes,
        io_reads,
        io_writes,
        io_read_bytes,
        io_write_bytes
    FROM endpoints
)
SELECT
    round(elapsed_seconds, 3) AS elapsed_seconds,
    round(database_read_blocks / NULLIF(elapsed_seconds, 0), 2) AS database_read_blocks_per_second,
    round(
        100.0 * database_hit_blocks
        / NULLIF(database_hit_blocks + database_read_blocks, 0),
        2
    ) AS interval_cache_hit_pct,
    round(io_reads / NULLIF(elapsed_seconds, 0), 2) AS pg_stat_io_reads_per_second,
    round(io_writes / NULLIF(elapsed_seconds, 0), 2) AS pg_stat_io_writes_per_second,
    pg_size_pretty((io_read_bytes / NULLIF(elapsed_seconds, 0))::bigint) AS pg_stat_io_read_throughput_per_second,
    pg_size_pretty((io_write_bytes / NULLIF(elapsed_seconds, 0))::bigint) AS pg_stat_io_write_throughput_per_second,
    pg_size_pretty((temp_bytes / NULLIF(elapsed_seconds, 0))::bigint) AS temp_throughput_per_second,
    pg_size_pretty((wal_bytes / NULLIF(elapsed_seconds, 0))::bigint) AS wal_generation_per_second,
    CASE
        WHEN io_reads IS NULL THEN 'PG15_FALLBACK_DATABASE_READ_RATE_ONLY'
        WHEN io_reads + io_writes = 0 THEN 'NO_IO_CHANGE_DURING_SHORT_SAMPLE'
        WHEN io_reads > io_writes * 2 THEN 'READ_DOMINATED_SAMPLE'
        WHEN io_writes > io_reads * 2 THEN 'WRITE_DOMINATED_SAMPLE'
        ELSE 'MIXED_IO_SAMPLE'
    END AS sample_diagnosis
FROM rates;

-- SAMPLE_OUTPUT_BEGIN
-- datname | buffer_cache_hit_pct | cumulative_database_read_bytes | interpretation
-- schema_name | relname | physical_blocks_read | relation_cache_hit_pct | diagnosis
-- elapsed_seconds | pg_stat_io_reads_per_second | pg_stat_io_writes_per_second | interval_cache_hit_pct | sample_diagnosis
-- SAMPLE_OUTPUT_END
