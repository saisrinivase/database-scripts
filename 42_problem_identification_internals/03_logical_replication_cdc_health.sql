/*
PostgreSQL DBA Script: Logical Replication CDC Health
Purpose: Diagnose publication, subscription, logical-slot, table synchronization, replica-identity, and CDC worker readiness.
Area: Problem Identification and Internals
Usage: Run on both publisher and subscriber databases; compare results with CDC connector and PostgreSQL logs.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only. Connection strings are intentionally excluded. Some subscription details require elevated privileges.
*/
SELECT
    p.pubname AS publication_name,
    pg_get_userbyid(p.pubowner) AS owner_name,
    p.puballtables,
    p.pubinsert,
    p.pubupdate,
    p.pubdelete,
    p.pubtruncate,
    count(pt.tablename) AS published_table_count,
    CASE
        WHEN NOT p.puballtables AND count(pt.tablename) = 0 THEN 'EMPTY_PUBLICATION'
        ELSE 'READY'
    END AS health_status
FROM pg_publication p
LEFT JOIN pg_publication_tables pt ON pt.pubname = p.pubname
GROUP BY p.oid, p.pubname, p.pubowner, p.puballtables, p.pubinsert, p.pubupdate, p.pubdelete, p.pubtruncate
ORDER BY p.pubname;

SELECT
    pt.pubname AS publication_name,
    pt.schemaname AS schema_name,
    pt.tablename AS table_name,
    c.relreplident AS replica_identity_code,
    CASE c.relreplident
        WHEN 'd' THEN 'DEFAULT_PRIMARY_KEY'
        WHEN 'n' THEN 'NOTHING'
        WHEN 'f' THEN 'FULL'
        WHEN 'i' THEN 'USING_INDEX'
    END AS replica_identity,
    i.indexrelid::regclass AS replica_identity_index,
    CASE
        WHEN c.relreplident = 'n' THEN 'HIGH: UPDATE and DELETE cannot be replicated.'
        WHEN c.relreplident = 'd' AND i.indexrelid IS NULL THEN 'HIGH: default identity but no valid primary key was found.'
        WHEN c.relreplident = 'f' THEN 'REVIEW: FULL works but increases WAL and matching cost.'
        ELSE 'READY'
    END AS diagnosis
FROM pg_publication_tables pt
JOIN pg_namespace n ON n.nspname = pt.schemaname
JOIN pg_class c ON c.relnamespace = n.oid AND c.relname = pt.tablename
LEFT JOIN pg_index i
    ON i.indrelid = c.oid
   AND ((c.relreplident = 'd' AND i.indisprimary) OR (c.relreplident = 'i' AND i.indisreplident))
ORDER BY diagnosis DESC, pt.pubname, pt.schemaname, pt.tablename;

SELECT
    s.subname AS subscription_name,
    pg_get_userbyid(s.subowner) AS owner_name,
    coalesce((to_jsonb(s)->>'subenabled')::boolean, false) AS enabled,
    to_jsonb(s)->>'subslotname' AS slot_name,
    to_jsonb(s)->'subpublications' AS publications,
    st.pid,
    st.relid::regclass AS synchronizing_relation,
    st.received_lsn,
    st.latest_end_lsn,
    st.last_msg_receipt_time,
    st.latest_end_time,
    clock_timestamp() - st.last_msg_receipt_time AS message_receipt_age,
    CASE
        WHEN NOT coalesce((to_jsonb(s)->>'subenabled')::boolean, false) THEN 'DISABLED'
        WHEN st.pid IS NULL THEN 'NO_ACTIVE_WORKER'
        WHEN st.last_msg_receipt_time < clock_timestamp() - interval '5 minutes' THEN 'STALE_MESSAGES'
        ELSE 'RUNNING'
    END AS health_status
FROM pg_subscription s
LEFT JOIN pg_stat_subscription st ON st.subid = s.oid
ORDER BY s.subname, st.relid NULLS FIRST;

SELECT
    slot_name,
    slot_type,
    plugin,
    database,
    active,
    active_pid,
    wal_status,
    safe_wal_size,
    pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) AS retained_wal_bytes,
    pg_size_pretty(coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn), 0)) AS retained_wal_pretty,
    CASE
        WHEN slot_type = 'logical' AND NOT active AND restart_lsn IS NOT NULL THEN 'INACTIVE_LOGICAL_SLOT_RETAINING_WAL'
        WHEN wal_status = 'lost' THEN 'UNUSABLE_LOST_WAL'
        WHEN safe_wal_size IS NOT NULL AND safe_wal_size < 1024::bigint * 1024 * 1024 THEN 'LOW_SAFE_WAL_HEADROOM'
        ELSE 'REVIEW_WITH_CDC_CONSUMER'
    END AS diagnosis
FROM pg_replication_slots
WHERE slot_type = 'logical'
ORDER BY retained_wal_bytes DESC NULLS LAST, slot_name;

SELECT
    name,
    setting,
    unit,
    context,
    pending_restart
FROM pg_settings
WHERE name IN (
    'wal_level',
    'max_replication_slots',
    'max_wal_senders',
    'max_logical_replication_workers',
    'max_sync_workers_per_subscription',
    'max_parallel_apply_workers_per_subscription',
    'max_worker_processes',
    'wal_sender_timeout',
    'wal_receiver_timeout'
)
ORDER BY name;

-- SAMPLE_OUTPUT_BEGIN
-- publication_name | published_table_count | health_status
-- subscription_name | enabled | pid | message_receipt_age | health_status
-- slot_name | slot_type | active | retained_wal_pretty | diagnosis
-- SAMPLE_OUTPUT_END
