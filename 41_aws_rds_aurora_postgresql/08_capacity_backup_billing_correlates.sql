/*
PostgreSQL DBA Script: AWS Capacity Backup Billing Correlates
Purpose: Deep-dive FreeStorageSpace, VolumeBytesUsed, backup retention storage, snapshot storage, and total backup billing with SQL-visible growth evidence.
Area: AWS RDS and Aurora PostgreSQL
Usage: Use AWS for exact managed-storage and billing values; use this script to identify database, object, WAL, and retention contributors.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only. PostgreSQL cannot see filesystem free space, Aurora internal allocations, snapshot sharing, or AWS billing records.
*/
SELECT
    datname,
    pg_database_size(datname) AS database_bytes,
    pg_size_pretty(pg_database_size(datname)) AS database_size,
    age(datfrozenxid) AS xid_age,
    datallowconn,
    datistemplate
FROM pg_database
ORDER BY database_bytes DESC;

WITH sizes AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS object_name,
        c.relkind,
        pg_relation_size(c.oid, 'main') AS main_fork_bytes,
        pg_indexes_size(c.oid) AS index_bytes,
        CASE
            WHEN c.reltoastrelid = 0 THEN 0
            ELSE pg_total_relation_size(c.reltoastrelid)
        END AS toast_bytes,
        pg_total_relation_size(c.oid) AS total_bytes
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r', 'm', 'p')
      AND n.nspname NOT IN ('pg_catalog', 'information_schema')
      AND n.nspname !~ '^pg_toast'
)
SELECT
    schema_name,
    object_name,
    relkind,
    main_fork_bytes,
    greatest(total_bytes - main_fork_bytes - index_bytes - toast_bytes, 0) AS auxiliary_fork_bytes,
    index_bytes,
    round(100.0 * index_bytes / NULLIF(total_bytes, 0), 2) AS index_pct,
    toast_bytes,
    round(100.0 * toast_bytes / NULLIF(total_bytes, 0), 2) AS toast_pct,
    total_bytes,
    pg_size_pretty(total_bytes) AS total_size
FROM sizes
ORDER BY total_bytes DESC
LIMIT 100;

WITH wal AS (
    SELECT wal_bytes::numeric, stats_reset
    FROM pg_stat_wal
),
slots AS (
    SELECT
        count(*) AS slot_count,
        count(*) FILTER (WHERE NOT active) AS inactive_slots,
        coalesce(sum(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)), 0)::numeric AS retained_wal_bytes
    FROM pg_replication_slots
    WHERE restart_lsn IS NOT NULL
)
SELECT
    w.wal_bytes,
    pg_size_pretty(w.wal_bytes::bigint) AS wal_generated_since_reset,
    w.stats_reset AS wal_stats_reset,
    s.slot_count,
    s.inactive_slots,
    s.retained_wal_bytes,
    pg_size_pretty(s.retained_wal_bytes::bigint) AS slot_retained_wal,
    CASE
        WHEN s.retained_wal_bytes >= 10::numeric * 1024 * 1024 * 1024 THEN 'Replication-slot retention is a material storage contributor.'
        WHEN s.inactive_slots > 0 THEN 'Inactive replication slots can retain WAL.'
        ELSE 'No large slot-retention signal in this snapshot.'
    END AS diagnosis
FROM wal w
CROSS JOIN slots s;

SELECT
    archived_count,
    failed_count,
    last_archived_wal,
    last_archived_time,
    last_failed_wal,
    last_failed_time,
    stats_reset,
    CASE
        WHEN current_setting('archive_mode') = 'off' THEN 'Archive mode is off; confirm the managed-service PITR design in AWS.'
        WHEN failed_count > 0 AND last_failed_time >= coalesce(last_archived_time, '-infinity'::timestamptz)
            THEN 'Latest visible archive attempt failed.'
        WHEN failed_count > 0 THEN 'Historical failures exist; confirm a newer successful archive.'
        ELSE 'No archive failure visible in PostgreSQL statistics.'
    END AS diagnosis
FROM pg_stat_archiver;

SELECT *
FROM (VALUES
    ('FreeStorageSpace', 'AWS_ONLY', 'Filesystem free bytes are not portable SQL. Alarm on AWS and use object growth to identify consumers.'),
    ('VolumeBytesUsed', 'AWS_ONLY_WITH_SQL_CORRELATION', 'Aurora volume usage includes service allocations and does not equal sum(pg_database_size).'),
    ('BackupRetentionPeriodStorageUsed', 'AWS_ONLY', 'AWS owns automated-backup retention accounting. Correlate with database size and WAL generation.'),
    ('SnapshotStorageUsed', 'AWS_ONLY', 'AWS owns manual snapshot accounting and clone sharing.'),
    ('TotalBackupStorageBilled', 'AWS_ONLY', 'AWS billing is authoritative; PostgreSQL SQL cannot reproduce it.')
) AS aws_capacity_boundary(metric_name, visibility, interpretation);

-- SAMPLE_OUTPUT_BEGIN
-- datname | database_bytes | database_size | xid_age
-- schema_name | object_name | main_fork_bytes | auxiliary_fork_bytes | index_bytes | index_pct | toast_bytes | toast_pct | total_size
-- SAMPLE_OUTPUT_END
