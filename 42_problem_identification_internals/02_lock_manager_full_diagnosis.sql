/*
PostgreSQL DBA Script: Lock Manager Full Diagnosis
Purpose: Detect blocked sessions and expose heavyweight, advisory, predicate, transaction, and fast-path lock pressure.
Area: Problem Identification and Internals
Usage: Run during lock waits, serialization failures, DDL stalls, or unexplained transaction latency.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only. PostgreSQL row locks normally appear as waits on transaction IDs rather than one pg_locks row per locked tuple.
*/
SELECT
    a.pid AS waiting_pid,
    a.usename,
    a.datname,
    a.application_name,
    now() - a.query_start AS query_age,
    now() - a.xact_start AS transaction_age,
    a.wait_event_type,
    a.wait_event,
    pg_blocking_pids(a.pid) AS blocking_pids,
    l.locktype,
    l.mode AS requested_mode,
    l.relation::regclass AS relation_name,
    l.page,
    l.tuple,
    l.transactionid,
    a.query
FROM pg_stat_activity a
LEFT JOIN pg_locks l
    ON l.pid = a.pid
   AND NOT l.granted
WHERE cardinality(pg_blocking_pids(a.pid)) > 0
   OR (a.wait_event_type = 'Lock' AND a.pid <> pg_backend_pid())
ORDER BY query_age DESC NULLS LAST, a.pid, l.locktype;

SELECT
    locktype,
    mode,
    granted,
    fastpath,
    count(*) AS lock_count,
    count(DISTINCT pid) AS backend_count,
    round(100.0 * count(*) / NULLIF(sum(count(*)) OVER (), 0), 2) AS pct_of_visible_locks,
    CASE
        WHEN NOT granted THEN 'WAITING_LOCK'
        WHEN mode = 'SIReadLock' THEN 'SERIALIZABLE_PREDICATE_LOCK'
        WHEN locktype = 'advisory' THEN 'APPLICATION_ADVISORY_LOCK'
        WHEN fastpath THEN 'FAST_PATH_LOCK'
        ELSE 'GRANTED_HEAVYWEIGHT_LOCK'
    END AS interpretation
FROM pg_locks
GROUP BY locktype, mode, granted, fastpath
ORDER BY granted, lock_count DESC, locktype, mode;

SELECT
    l.pid,
    a.usename,
    a.application_name,
    a.state,
    l.granted,
    l.mode,
    d.datname AS database_name,
    l.classid::bigint AS key_part_1,
    l.objid::bigint AS key_part_2,
    l.objsubid AS key_format,
    CASE
        WHEN l.objsubid = 1 THEN ((l.classid::bigint << 32) | l.objid::bigint)::text
        ELSE l.classid::text || ',' || l.objid::text
    END AS advisory_key,
    now() - a.xact_start AS transaction_age,
    a.query
FROM pg_locks l
LEFT JOIN pg_stat_activity a ON a.pid = l.pid
LEFT JOIN pg_database d ON d.oid = l.database
WHERE l.locktype = 'advisory'
ORDER BY l.granted, transaction_age DESC NULLS LAST, l.pid;

SELECT
    name,
    setting,
    unit,
    context,
    pending_restart,
    CASE name
        WHEN 'deadlock_timeout' THEN 'Controls when PostgreSQL performs the relatively expensive deadlock check.'
        WHEN 'lock_timeout' THEN 'Session default; zero means no lock-wait timeout.'
        WHEN 'max_locks_per_transaction' THEN 'Average shared lock-table capacity per transaction.'
        WHEN 'max_pred_locks_per_transaction' THEN 'Average predicate-lock capacity for serializable transactions.'
        WHEN 'max_pred_locks_per_relation' THEN 'Predicate locks promoted to relation level after this threshold.'
        WHEN 'max_pred_locks_per_page' THEN 'Tuple predicate locks promoted to page level after this threshold.'
    END AS purpose
FROM pg_settings
WHERE name IN (
    'deadlock_timeout',
    'lock_timeout',
    'max_locks_per_transaction',
    'max_pred_locks_per_transaction',
    'max_pred_locks_per_relation',
    'max_pred_locks_per_page'
)
ORDER BY name;

-- SAMPLE_OUTPUT_BEGIN
-- waiting_pid | wait_event | blocking_pids | locktype | requested_mode | relation_name | query
-- locktype | mode | granted | fastpath | lock_count | backend_count | pct_of_visible_locks | interpretation
-- SAMPLE_OUTPUT_END
