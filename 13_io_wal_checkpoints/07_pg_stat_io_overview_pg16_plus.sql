/*
PostgreSQL DBA Script: Pg Stat IO Overview Pg16 Plus
Purpose: Provide consolidated I/O stats from pg_stat_io view.
Area: I/O, WAL, and Checkpoints
Usage: PostgreSQL 16+ for pg_stat_io details. Safe for pgAdmin and psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic. Returns a guidance row when pg_stat_io is unavailable.
*/
CREATE TEMP TABLE IF NOT EXISTS pg_stat_io_overview_result (
    backend_type text,
    object text,
    context text,
    reads bigint,
    read_time double precision,
    writes bigint,
    write_time double precision,
    writebacks bigint,
    writeback_time double precision,
    extends bigint,
    extend_time double precision,
    fsyncs bigint,
    fsync_time double precision,
    note text
);

TRUNCATE pg_stat_io_overview_result;

DO $$
BEGIN
    IF to_regclass('pg_catalog.pg_stat_io') IS NOT NULL THEN
        EXECUTE $sql$
            INSERT INTO pg_stat_io_overview_result
            SELECT
                backend_type::text,
                object::text,
                context::text,
                reads,
                read_time,
                writes,
                write_time,
                writebacks,
                writeback_time,
                extends,
                extend_time,
                fsyncs,
                fsync_time,
                'pg_stat_io available'::text
            FROM pg_stat_io
        $sql$;
    ELSE
        INSERT INTO pg_stat_io_overview_result (
            backend_type,
            object,
            context,
            note
        )
        VALUES (
            'not_available',
            'pg_stat_io',
            'server_version_' || current_setting('server_version_num'),
            'pg_stat_io is available from PostgreSQL 16+. Use pg_stat_database timing proxies on older versions.'
        );
    END IF;
END $$;

SELECT *
FROM pg_stat_io_overview_result
ORDER BY read_time DESC NULLS LAST, write_time DESC NULLS LAST, backend_type, object, context;

-- SAMPLE_OUTPUT_BEGIN
-- backend_type | object   | context | reads | read_time | writes | write_time | note
-- -------------+----------+---------+-------+-----------+--------+------------+-------------------
-- client backend | relation | normal | 1000 |      1.20 |    500 |       0.80 | pg_stat_io available
-- SAMPLE_OUTPUT_END
