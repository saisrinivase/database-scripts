/*
PostgreSQL DBA Script: AWS XID Vacuum Wraparound Pressure
Purpose: Deep-dive MaximumUsedTransactionIDs with database/table XID age, freeze percentage, vacuum triggers, workers, and blockers.
Area: AWS RDS and Aurora PostgreSQL
Usage: Run immediately when MaximumUsedTransactionIDs rises; inspect the highest percentage and cleanup blockers first.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only. PostgreSQL 15+ and managed-service safe with monitoring privileges.
*/
WITH limits AS (
    SELECT
        current_setting('autovacuum_freeze_max_age')::numeric AS freeze_max_age,
        current_setting('autovacuum_multixact_freeze_max_age')::numeric AS multixact_freeze_max_age
)
SELECT
    d.datname,
    age(d.datfrozenxid)::numeric AS xid_age,
    round(100.0 * age(d.datfrozenxid)::numeric / NULLIF(l.freeze_max_age, 0), 2) AS xid_age_pct_of_autovacuum_limit,
    mxid_age(d.datminmxid)::numeric AS multixact_age,
    round(100.0 * mxid_age(d.datminmxid)::numeric / NULLIF(l.multixact_freeze_max_age, 0), 2) AS multixact_age_pct_of_limit,
    l.freeze_max_age,
    l.multixact_freeze_max_age,
    CASE
        WHEN age(d.datfrozenxid)::numeric >= l.freeze_max_age * 0.90 THEN 'CRITICAL: database XID age is at least 90 percent of autovacuum freeze limit.'
        WHEN age(d.datfrozenxid)::numeric >= l.freeze_max_age * 0.75 THEN 'HIGH: database XID age is at least 75 percent of autovacuum freeze limit.'
        WHEN mxid_age(d.datminmxid)::numeric >= l.multixact_freeze_max_age * 0.75 THEN 'HIGH: database multixact age is at least 75 percent of limit.'
        ELSE 'No database-level threshold breach in this snapshot.'
    END AS diagnosis
FROM pg_database d
CROSS JOIN limits l
WHERE d.datallowconn
ORDER BY xid_age DESC;

WITH limits AS (
    SELECT current_setting('autovacuum_freeze_max_age')::numeric AS freeze_max_age
)
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    age(c.relfrozenxid)::numeric AS xid_age,
    round(100.0 * age(c.relfrozenxid)::numeric / NULLIF(l.freeze_max_age, 0), 2) AS freeze_age_pct,
    s.n_live_tup,
    s.n_dead_tup,
    round(100.0 * s.n_dead_tup / NULLIF(s.n_live_tup + s.n_dead_tup, 0), 2) AS dead_tuple_pct,
    s.last_vacuum,
    s.last_autovacuum,
    c.reloptions,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size,
    CASE
        WHEN age(c.relfrozenxid)::numeric >= l.freeze_max_age * 0.90 THEN 'CRITICAL: prioritize VACUUM FREEZE after clearing blockers.'
        WHEN age(c.relfrozenxid)::numeric >= l.freeze_max_age * 0.75 THEN 'HIGH: validate autovacuum throughput and table overrides.'
        WHEN s.n_dead_tup > greatest(s.n_live_tup, 1) * 0.20 THEN 'Dead-tuple pressure can increase required vacuum work.'
        ELSE 'Ranked table; monitor trend.'
    END AS diagnosis
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_stat_all_tables s ON s.relid = c.oid
CROSS JOIN limits l
WHERE c.relkind IN ('r', 'm')
  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
  AND n.nspname !~ '^pg_toast'
ORDER BY xid_age DESC
LIMIT 100;

SELECT
    count(*) FILTER (WHERE backend_type = 'autovacuum worker') AS active_autovacuum_workers,
    current_setting('autovacuum_max_workers')::integer AS autovacuum_max_workers,
    count(*) FILTER (WHERE backend_type = 'autovacuum launcher') AS autovacuum_launchers,
    CASE
        WHEN count(*) FILTER (WHERE backend_type = 'autovacuum worker')
             >= current_setting('autovacuum_max_workers')::integer
            THEN 'All configured autovacuum workers are active; inspect backlog and I/O pressure.'
        ELSE 'Autovacuum worker capacity is currently available.'
    END AS diagnosis
FROM pg_stat_activity;

SELECT
    pid,
    usename,
    datname,
    application_name,
    state,
    clock_timestamp() - xact_start AS transaction_age,
    age(backend_xmin) AS backend_xmin_age,
    wait_event_type,
    wait_event,
    regexp_replace(query, '\s+', ' ', 'g') AS complete_query_text,
    CASE
        WHEN state = 'idle in transaction' THEN 'Idle transaction can hold an old snapshot and delay cleanup.'
        WHEN backend_xmin IS NOT NULL THEN 'Backend xmin can hold back global visibility.'
        ELSE 'Long transaction can delay vacuum progress.'
    END AS vacuum_impact
FROM pg_stat_activity
WHERE pid <> pg_backend_pid()
  AND xact_start IS NOT NULL
  AND (
      state = 'idle in transaction'
      OR backend_xmin IS NOT NULL
      OR clock_timestamp() - xact_start > interval '5 minutes'
  )
ORDER BY xact_start;

SELECT
    p.pid,
    n.nspname AS schema_name,
    c.relname AS table_name,
    p.phase,
    p.heap_blks_total,
    p.heap_blks_scanned,
    p.heap_blks_vacuumed,
    round(100.0 * p.heap_blks_scanned / NULLIF(p.heap_blks_total, 0), 2) AS heap_scan_pct,
    round(100.0 * p.heap_blks_vacuumed / NULLIF(p.heap_blks_total, 0), 2) AS heap_vacuum_pct,
    p.index_vacuum_count
FROM pg_stat_progress_vacuum p
JOIN pg_class c ON c.oid = p.relid
JOIN pg_namespace n ON n.oid = c.relnamespace
ORDER BY p.pid;

-- SAMPLE_OUTPUT_BEGIN
-- datname | xid_age | xid_age_pct_of_autovacuum_limit | diagnosis
-- schema_name | table_name | freeze_age_pct | dead_tuple_pct | diagnosis
-- SAMPLE_OUTPUT_END
