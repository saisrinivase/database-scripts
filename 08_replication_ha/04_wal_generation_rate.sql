/*
PostgreSQL DBA Script: WAL Generation Rate
Purpose: Estimate WAL generation rate based on pg_stat_wal counters.
Area: Replication and HA
Usage: PostgreSQL 14+ (pg_stat_wal).
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
SELECT
    wal_records,
    wal_fpi,
    wal_bytes,
    stats_reset,
    extract(epoch FROM (now() - stats_reset))::bigint AS elapsed_seconds,
    CASE
        WHEN extract(epoch FROM (now() - stats_reset)) > 0
            THEN (wal_bytes / extract(epoch FROM (now() - stats_reset)))::numeric(20,2)
        ELSE NULL
    END AS wal_bytes_per_second,
    CASE
        WHEN extract(epoch FROM (now() - stats_reset)) > 0
            THEN pg_size_pretty((wal_bytes / extract(epoch FROM (now() - stats_reset)))::bigint)
        ELSE NULL
    END AS wal_rate_pretty_per_second
FROM pg_stat_wal;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  wal_records | wal_fpi |  wal_bytes  |          stats_reset          | elapsed_seconds | wal_bytes_per_second | wal_rate_pretty_per_second 
-- -------------+---------+-------------+-------------------------------+-----------------+----------------------+----------------------------
--     62850486 |  690812 | 33184403795 | 2026-01-31 20:40:48.109778-05 |         1551763 |             21384.96 | 21 kB
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
