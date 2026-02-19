/*
Purpose: Estimate WAL generation rate based on pg_stat_wal counters.
Area: Replication and HA
Usage: PostgreSQL 14+ (pg_stat_wal).
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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 wal_records | wal_fpi |  wal_bytes  |          stats_reset          | elapsed_seconds | wal_bytes_per_second | wal_rate_pretty_per_second 
-------------+---------+-------------+-------------------------------+-----------------+----------------------+----------------------------
    48278912 |  675399 | 31813791436 | 2026-01-31 20:40:48.109778-05 |         1544544 |             20597.53 | 20 kB
(1 row)


SAMPLE_OUTPUT_END */
