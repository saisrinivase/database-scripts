/*
Purpose: Provide consolidated I/O stats from pg_stat_io view.
Area: I/O, WAL, and Checkpoints
Usage: PostgreSQL 16+ only.
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
