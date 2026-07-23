/*
PostgreSQL DBA Script: PgAdmin Safe Pg Stat IO Overview
Purpose: pgAdmin-safe PostgreSQL 16+ pg_stat_io overview with a clear fallback on older releases.
Scope: I/O by backend type, object, and context for SME diagnosis of read, write, extend, fsync, and eviction pressure.
pgAdmin: Safe to run in Query Tool. Uses a temporary helper function only.
Sample output:
 backend_type       | object   | context | reads | writes | fsyncs | diagnosis
-------------------+----------+---------+-------+--------+--------+-------------------------------
 client backend    | relation | normal  | 1200  | 400    | 0      | Review read/write hot spots.
 pg_stat_io        | n/a      | n/a     |       |        |        | Not available before PG16.
*/

CREATE OR REPLACE FUNCTION pg_temp.pgadmin_pg_stat_io_overview()
RETURNS TABLE (
    backend_type text,
    object text,
    context text,
    reads numeric,
    read_time_ms numeric,
    writes numeric,
    write_time_ms numeric,
    extends numeric,
    extend_time_ms numeric,
    total_bytes numeric,
    evictions numeric,
    reuses numeric,
    fsyncs numeric,
    fsync_time_ms numeric,
    diagnosis text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_io') IS NULL THEN
        RETURN QUERY
        SELECT
            'pg_stat_io unavailable'::text,
            'n/a'::text,
            'n/a'::text,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            'pg_stat_io exists in PostgreSQL 16+. Use OS/cloud I/O counters or pg_stat_database on older releases.'::text;
        RETURN;
    END IF;

    RETURN QUERY EXECUTE
    $sql$
        SELECT
            backend_type::text,
            object::text,
            context::text,
            sum(reads)::numeric AS reads,
            round(sum(read_time)::numeric, 2) AS read_time_ms,
            sum(writes)::numeric AS writes,
            round(sum(write_time)::numeric, 2) AS write_time_ms,
            sum(extends)::numeric AS extends,
            round(sum(extend_time)::numeric, 2) AS extend_time_ms,
            sum(coalesce(read_bytes, 0) + coalesce(write_bytes, 0) + coalesce(extend_bytes, 0))::numeric AS total_bytes,
            sum(evictions)::numeric AS evictions,
            sum(reuses)::numeric AS reuses,
            sum(fsyncs)::numeric AS fsyncs,
            round(sum(fsync_time)::numeric, 2) AS fsync_time_ms,
            CASE
                WHEN sum(read_time) > 0 AND sum(reads) > 0 AND sum(read_time) / NULLIF(sum(reads), 0) > 10
                    THEN 'High average read latency. Check storage latency, cache hit ratio, and top read queries.'
                WHEN sum(write_time) > 0 AND sum(writes) > 0 AND sum(write_time) / NULLIF(sum(writes), 0) > 10
                    THEN 'High average write latency. Check checkpoints, WAL pressure, and storage write latency.'
                WHEN sum(fsync_time) > 0
                    THEN 'Fsync time present. Correlate with checkpoints, WAL sync, and storage stalls.'
                WHEN sum(evictions) > sum(reuses) AND sum(evictions) > 0
                    THEN 'Buffer churn visible. Review shared_buffers, working set size, and scan-heavy SQL.'
                ELSE 'Normal or low I/O pressure in this bucket.'
            END::text AS diagnosis
        FROM pg_stat_io
        GROUP BY backend_type, object, context
        ORDER BY (sum(read_time) + sum(write_time) + sum(extend_time) + sum(fsync_time)) DESC NULLS LAST,
                 sum(reads + writes + extends + fsyncs) DESC NULLS LAST
    $sql$;
END;
$$;

SELECT *
FROM pg_temp.pgadmin_pg_stat_io_overview();

-- SAMPLE_OUTPUT_BEGIN
-- backend_type    | object   | context | reads | read_time_ms | writes | total_bytes | diagnosis
-- ---------------+----------+---------+-------+--------------+--------+-------------+------------------------------
-- client backend | relation | normal  | 1200  | 45.10        | 300    | 125829120   | Normal or low I/O pressure...
-- SAMPLE_OUTPUT_END
