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
