/*
Purpose: Identify WAL retention risk from replication slots that can cause disk pressure.
Area: Physical and Cloud Diagnostics
Usage: Run on primary; large retained WAL indicates downstream lag or inactive slot.
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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 slot_name | slot_type | active | temporary | restart_lsn | confirmed_flush_lsn | retained_wal_bytes | retained_wal_pretty | wal_status | safe_wal_size 
-----------+-----------+--------+-----------+-------------+---------------------+--------------------+---------------------+------------+---------------
(0 rows)


SAMPLE_OUTPUT_END */
