/*
PostgreSQL DBA Script: AWS Storage IO Cache Temp Pressure
Purpose: Deep-dive storage IOPS, latency, throughput, queue, credits, local/ephemeral/temp storage, Aurora volume I/O, and cache-hit alarms.
Area: AWS RDS and Aurora PostgreSQL
Usage: Compare results with the same CloudWatch period; calculate deltas for cumulative PostgreSQL counters.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only except for a pg_temp function. AWS remains authoritative for physical storage, credits, queue depth, and free bytes.
*/
SELECT
    'database_io_cache_temp' AS report_section,
    datname,
    blks_read,
    blks_hit,
    round(100.0 * blks_hit / NULLIF(blks_hit + blks_read, 0), 2) AS cache_hit_pct,
    temp_files,
    temp_bytes,
    pg_size_pretty(temp_bytes) AS temp_bytes_pretty,
    blk_read_time AS cumulative_read_time_ms,
    blk_write_time AS cumulative_write_time_ms,
    stats_reset,
    CASE
        WHEN temp_bytes >= 10::bigint * 1024 * 1024 * 1024 THEN 'HIGH historical temp volume; calculate interval delta and inspect spilling SQL.'
        WHEN blks_read > blks_hit THEN 'Physical-read counter exceeds cache hits for this database.'
        WHEN blk_read_time > 0 OR blk_write_time > 0 THEN 'I/O timing evidence exists; calculate interval latency and throughput.'
        ELSE 'No strong cumulative database I/O warning.'
    END AS diagnosis
FROM pg_stat_database
WHERE datname IS NOT NULL
ORDER BY blks_read DESC, temp_bytes DESC;

SELECT
    schemaname,
    relname,
    heap_blks_read,
    heap_blks_hit,
    idx_blks_read,
    idx_blks_hit,
    toast_blks_read,
    toast_blks_hit,
    (heap_blks_read + idx_blks_read + toast_blks_read) AS physical_blocks_read,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    CASE
        WHEN heap_blks_read > heap_blks_hit THEN 'Heap physical-read hotspot.'
        WHEN idx_blks_read > idx_blks_hit THEN 'Index physical-read hotspot.'
        ELSE 'Ranked I/O contributor; compare interval deltas.'
    END AS diagnosis
FROM pg_statio_user_tables
ORDER BY physical_blocks_read DESC
LIMIT 50;

SELECT
    backend_type,
    wait_event_type,
    wait_event,
    count(*) AS waiting_backends,
    max(clock_timestamp() - query_start) AS longest_query_age,
    string_agg(DISTINCT regexp_replace(query, '\s+', ' ', 'g'), E'\n') AS complete_query_texts
FROM pg_stat_activity
WHERE wait_event_type = 'IO'
   OR wait_event ILIKE '%datafile%'
   OR wait_event ILIKE '%temp%'
GROUP BY backend_type, wait_event_type, wait_event
ORDER BY waiting_backends DESC, wait_event;

CREATE OR REPLACE FUNCTION pg_temp.aws_pg_stat_io_pressure()
RETURNS TABLE (
    backend_type text,
    object_name text,
    context_name text,
    reads numeric,
    read_time_ms numeric,
    average_read_ms numeric,
    writes numeric,
    write_time_ms numeric,
    average_write_ms numeric,
    extends numeric,
    fsyncs numeric,
    evictions numeric,
    stats_reset timestamptz,
    diagnosis text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_io') IS NULL THEN
        RETURN;
    END IF;

    RETURN QUERY EXECUTE $query$
        SELECT
            backend_type,
            object,
            context,
            coalesce(reads, 0)::numeric,
            coalesce(read_time, 0)::numeric,
            round(coalesce(read_time, 0)::numeric / NULLIF(reads, 0), 3),
            coalesce(writes, 0)::numeric,
            coalesce(write_time, 0)::numeric,
            round(coalesce(write_time, 0)::numeric / NULLIF(writes, 0), 3),
            coalesce(extends, 0)::numeric,
            coalesce(fsyncs, 0)::numeric,
            coalesce(evictions, 0)::numeric,
            stats_reset,
            CASE
                WHEN coalesce(read_time, 0) / NULLIF(reads, 0) >= 10 THEN 'High average read timing in this bucket.'
                WHEN coalesce(write_time, 0) / NULLIF(writes, 0) >= 10 THEN 'High average write timing in this bucket.'
                WHEN coalesce(evictions, 0) > 0 THEN 'Buffer evictions exist; compare interval rate with cache and memory pressure.'
                ELSE 'Capture two snapshots matching the CloudWatch period.'
            END
        FROM pg_stat_io
        ORDER BY
            coalesce(read_time, 0) + coalesce(write_time, 0) DESC,
            coalesce(reads, 0) + coalesce(writes, 0) DESC
    $query$;
END;
$$;

SELECT *
FROM pg_temp.aws_pg_stat_io_pressure();

-- SAMPLE_OUTPUT_BEGIN
-- datname | cache_hit_pct | temp_bytes_pretty | cumulative_read_time_ms | diagnosis
-- backend_type | object_name | reads | average_read_ms | writes | average_write_ms | diagnosis
-- SAMPLE_OUTPUT_END
