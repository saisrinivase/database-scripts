/*
PostgreSQL DBA Script: Vacuum Internal Pressure Dashboard
Purpose: Explain how autovacuum decisions, worker capacity, cleanup blockers, dead tuples, and freeze age combine into vacuum pressure.
Area: Internals Deep Dive
Usage: Run in pgAdmin Query Tool or psql on PostgreSQL 15+. Review all four result sets in order.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom for representative result shapes.
Notes: Read-only, extension-free, and suitable for self-managed or managed PostgreSQL. Statistics are database-local.
*/

-- Result 1: cluster vacuum settings and worker utilization.
WITH settings AS (
    SELECT
        current_setting('autovacuum') AS autovacuum_enabled,
        current_setting('autovacuum_max_workers')::numeric AS max_workers,
        current_setting('autovacuum_naptime') AS naptime,
        current_setting('autovacuum_vacuum_threshold')::numeric AS vacuum_threshold,
        current_setting('autovacuum_vacuum_scale_factor')::numeric AS vacuum_scale_factor,
        current_setting('autovacuum_analyze_threshold')::numeric AS analyze_threshold,
        current_setting('autovacuum_analyze_scale_factor')::numeric AS analyze_scale_factor,
        current_setting('autovacuum_freeze_max_age')::numeric AS freeze_max_age,
        current_setting('autovacuum_multixact_freeze_max_age')::numeric AS multixact_freeze_max_age
),
workers AS (
    SELECT count(*)::numeric AS active_workers
    FROM pg_stat_activity
    WHERE backend_type = 'autovacuum worker'
)
SELECT
    s.autovacuum_enabled,
    w.active_workers,
    s.max_workers AS configured_max_workers,
    round(100.0 * w.active_workers / NULLIF(s.max_workers, 0), 2) AS worker_utilization_pct,
    s.naptime,
    s.vacuum_threshold,
    s.vacuum_scale_factor,
    s.analyze_threshold,
    s.analyze_scale_factor,
    s.freeze_max_age,
    s.multixact_freeze_max_age,
    CASE
        WHEN s.autovacuum_enabled <> 'on' THEN 'CRITICAL: cluster autovacuum is disabled.'
        WHEN w.active_workers >= s.max_workers THEN 'PRESSURE: every autovacuum worker is busy; inspect the table backlog.'
        ELSE 'Worker capacity is currently available; table-level backlog can still exist.'
    END AS diagnosis
FROM settings s
CROSS JOIN workers w;

-- Result 2: table backlog using effective table overrides when present.
WITH cluster_settings AS (
    SELECT
        current_setting('autovacuum_vacuum_threshold')::numeric AS vacuum_threshold,
        current_setting('autovacuum_vacuum_scale_factor')::numeric AS vacuum_scale_factor,
        current_setting('autovacuum_analyze_threshold')::numeric AS analyze_threshold,
        current_setting('autovacuum_analyze_scale_factor')::numeric AS analyze_scale_factor,
        current_setting('autovacuum_freeze_max_age')::numeric AS freeze_max_age
),
table_settings AS (
    SELECT
        c.oid,
        n.nspname AS schema_name,
        c.relname AS table_name,
        c.reltuples,
        coalesce(
            (SELECT option_value::numeric FROM pg_options_to_table(c.reloptions)
             WHERE option_name = 'autovacuum_vacuum_threshold'),
            cs.vacuum_threshold
        ) AS vacuum_threshold,
        coalesce(
            (SELECT option_value::numeric FROM pg_options_to_table(c.reloptions)
             WHERE option_name = 'autovacuum_vacuum_scale_factor'),
            cs.vacuum_scale_factor
        ) AS vacuum_scale_factor,
        coalesce(
            (SELECT option_value::numeric FROM pg_options_to_table(c.reloptions)
             WHERE option_name = 'autovacuum_analyze_threshold'),
            cs.analyze_threshold
        ) AS analyze_threshold,
        coalesce(
            (SELECT option_value::numeric FROM pg_options_to_table(c.reloptions)
             WHERE option_name = 'autovacuum_analyze_scale_factor'),
            cs.analyze_scale_factor
        ) AS analyze_scale_factor,
        coalesce(
            (SELECT option_value::boolean FROM pg_options_to_table(c.reloptions)
             WHERE option_name = 'autovacuum_enabled'),
            true
        ) AS table_autovacuum_enabled,
        cs.freeze_max_age
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    CROSS JOIN cluster_settings cs
    WHERE c.relkind IN ('r', 'm')
      AND n.nspname NOT IN ('pg_catalog', 'information_schema')
      AND n.nspname !~ '^pg_toast'
),
pressure AS (
    SELECT
        ts.*,
        coalesce(st.n_live_tup, 0) AS n_live_tup,
        coalesce(st.n_dead_tup, 0) AS n_dead_tup,
        coalesce(st.n_mod_since_analyze, 0) AS n_mod_since_analyze,
        st.last_vacuum,
        st.last_autovacuum,
        st.last_analyze,
        st.last_autoanalyze,
        age(c.relfrozenxid)::numeric AS xid_age,
        greatest(
            ts.vacuum_threshold + ts.vacuum_scale_factor * greatest(ts.reltuples, 0)::numeric,
            1::numeric
        ) AS vacuum_trigger,
        greatest(
            ts.analyze_threshold + ts.analyze_scale_factor * greatest(ts.reltuples, 0)::numeric,
            1::numeric
        ) AS analyze_trigger,
        pg_total_relation_size(ts.oid) AS total_bytes
    FROM table_settings ts
    JOIN pg_class c ON c.oid = ts.oid
    LEFT JOIN pg_stat_all_tables st ON st.relid = ts.oid
)
SELECT
    schema_name,
    table_name,
    pg_size_pretty(total_bytes) AS total_size,
    n_live_tup,
    n_dead_tup,
    round(100.0 * n_dead_tup / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_tuple_pct,
    ceil(vacuum_trigger)::bigint AS estimated_vacuum_trigger,
    round(100.0 * n_dead_tup / NULLIF(vacuum_trigger, 0), 2) AS vacuum_trigger_pct,
    n_mod_since_analyze,
    ceil(analyze_trigger)::bigint AS estimated_analyze_trigger,
    round(100.0 * n_mod_since_analyze / NULLIF(analyze_trigger, 0), 2) AS analyze_trigger_pct,
    xid_age::bigint,
    round(100.0 * xid_age / NULLIF(freeze_max_age, 0), 2) AS freeze_age_pct,
    table_autovacuum_enabled,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    CASE
        WHEN NOT table_autovacuum_enabled THEN 'CRITICAL: autovacuum disabled for this table.'
        WHEN xid_age >= freeze_max_age * 0.90 THEN 'CRITICAL: anti-wraparound vacuum risk.'
        WHEN n_dead_tup >= vacuum_trigger * 2 THEN 'HIGH: dead tuples exceed twice the estimated vacuum trigger.'
        WHEN n_dead_tup >= vacuum_trigger THEN 'REVIEW: estimated vacuum trigger has been reached.'
        WHEN n_mod_since_analyze >= analyze_trigger THEN 'REVIEW: estimated analyze trigger has been reached.'
        ELSE 'No trigger breach detected in this snapshot.'
    END AS diagnosis,
    CASE
        WHEN NOT table_autovacuum_enabled THEN 'Confirm the exception is intentional and schedule manual VACUUM/ANALYZE.'
        WHEN xid_age >= freeze_max_age * 0.90 THEN 'Clear old snapshots and prioritize VACUUM FREEZE.'
        WHEN n_dead_tup >= vacuum_trigger THEN 'Check active workers, blockers, I/O latency, and per-table vacuum cost settings.'
        WHEN n_mod_since_analyze >= analyze_trigger THEN 'Run or allow ANALYZE so the planner receives current statistics.'
        ELSE 'Trend this table over time; a single quiet snapshot does not prove adequate throughput.'
    END AS recommended_action
FROM pressure
WHERE n_dead_tup >= vacuum_trigger
   OR n_mod_since_analyze >= analyze_trigger
   OR xid_age >= freeze_max_age * 0.50
   OR NOT table_autovacuum_enabled
ORDER BY
    (NOT table_autovacuum_enabled) DESC,
    (xid_age / NULLIF(freeze_max_age, 0)) DESC,
    (n_dead_tup / NULLIF(vacuum_trigger, 0)) DESC,
    total_bytes DESC
LIMIT 100;

-- Result 3: sessions whose snapshots can prevent tuple removal and catalog cleanup.
SELECT
    a.pid,
    a.usename,
    a.datname,
    a.application_name,
    a.client_addr,
    a.state,
    clock_timestamp() - a.xact_start AS transaction_age,
    clock_timestamp() - a.query_start AS query_age,
    age(a.backend_xmin) AS backend_xmin_age,
    a.wait_event_type,
    a.wait_event,
    regexp_replace(a.query, '\s+', ' ', 'g') AS query_text,
    CASE
        WHEN a.state = 'idle in transaction' THEN 'Idle transaction holds an old snapshot and can block vacuum cleanup.'
        WHEN a.backend_xmin IS NOT NULL THEN 'Backend xmin can hold back global visibility and catalog cleanup.'
        ELSE 'Long transaction can retain locks or an old snapshot.'
    END AS vacuum_impact,
    'Validate application ownership, then commit, roll back, or terminate only through an approved incident action.' AS recommended_action
FROM pg_stat_activity a
WHERE a.pid <> pg_backend_pid()
  AND a.xact_start IS NOT NULL
  AND (
      a.state = 'idle in transaction'
      OR a.backend_xmin IS NOT NULL
      OR clock_timestamp() - a.xact_start > interval '5 minutes'
  )
ORDER BY a.xact_start;

-- Result 4: running vacuum phase and progress. Zero rows means no VACUUM is active now.
SELECT
    p.pid,
    n.nspname AS schema_name,
    c.relname AS table_name,
    a.backend_type,
    p.phase,
    p.heap_blks_total,
    p.heap_blks_scanned,
    p.heap_blks_vacuumed,
    round(100.0 * p.heap_blks_scanned / NULLIF(p.heap_blks_total, 0), 2) AS heap_scan_pct,
    round(100.0 * p.heap_blks_vacuumed / NULLIF(p.heap_blks_total, 0), 2) AS heap_vacuum_pct,
    p.index_vacuum_count,
    clock_timestamp() - a.query_start AS elapsed,
    a.wait_event_type,
    a.wait_event,
    regexp_replace(a.query, '\s+', ' ', 'g') AS query_text,
    CASE
        WHEN a.wait_event_type = 'Lock' THEN 'VACUUM is waiting on a lock; identify the blocker.'
        WHEN a.wait_event_type = 'IO' THEN 'VACUUM is waiting on I/O; correlate with storage and checkpoint pressure.'
        WHEN p.phase = 'vacuuming indexes' THEN 'Index cleanup is active; large or numerous indexes can dominate elapsed time.'
        WHEN p.phase = 'vacuuming heap' THEN 'Heap cleanup is active after scanning.'
        ELSE 'Use phase and progress percentages to determine where time is spent.'
    END AS diagnosis
FROM pg_stat_progress_vacuum p
JOIN pg_class c ON c.oid = p.relid
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_stat_activity a ON a.pid = p.pid
ORDER BY elapsed DESC NULLS LAST;

-- SAMPLE_OUTPUT_BEGIN
-- Result 1: autovacuum_enabled | active_workers | configured_max_workers | worker_utilization_pct | diagnosis
-- Result 2: schema_name | table_name | vacuum_trigger_pct | analyze_trigger_pct | freeze_age_pct | diagnosis
-- Result 3: pid | transaction_age | backend_xmin_age | query_text | vacuum_impact
-- Result 4: pid | table_name | phase | heap_scan_pct | heap_vacuum_pct | diagnosis
-- SAMPLE_OUTPUT_END
