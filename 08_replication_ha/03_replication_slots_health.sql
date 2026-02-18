/*
Purpose: Inspect replication slots and retained WAL volume.
Area: Replication and HA
Usage: Large retained bytes can cause WAL disk growth.
*/
SELECT
    slot_name,
    slot_type,
    active,
    temporary,
    restart_lsn,
    confirmed_flush_lsn,
    pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) AS retained_wal_bytes,
    pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)::bigint) AS retained_wal_pretty,
    wal_status,
    safe_wal_size
FROM pg_replication_slots
ORDER BY retained_wal_bytes DESC NULLS LAST;
