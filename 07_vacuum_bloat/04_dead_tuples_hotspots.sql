/*
PostgreSQL DBA Script: Dead Tuples Hotspots
Purpose: Rank tables by dead tuple pressure, explain why it matters, and recommend cleanup actions.
Area: Vacuum and Bloat
Usage: Use during bloat, slow query, storage growth, or autovacuum investigations. High dead tuple pressure means old row versions are waiting for cleanup; if ignored, tables and indexes can grow, scans can slow down, cache efficiency can fall, and anti-wraparound/autovacuum work can become more disruptive.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic. Dead tuple counts are estimates from statistics; run ANALYZE or wait for stats refresh if numbers look stale.
*/
WITH table_stats AS (
    SELECT
        s.relid,
        s.schemaname AS schema_name,
        s.relname AS table_name,
        s.n_live_tup,
        s.n_dead_tup,
        s.seq_scan,
        s.idx_scan,
        s.n_tup_ins,
        s.n_tup_upd,
        s.n_tup_del,
        s.n_tup_hot_upd,
        s.vacuum_count,
        s.autovacuum_count,
        s.last_vacuum,
        s.last_autovacuum,
        pg_total_relation_size(s.relid) AS total_bytes,
        coalesce(c.reloptions, ARRAY[]::text[]) AS reloptions,
        'autovacuum_enabled=false' = ANY(coalesce(c.reloptions, ARRAY[]::text[])) AS autovacuum_disabled
    FROM pg_stat_user_tables s
    JOIN pg_class c
        ON c.oid = s.relid
),
settings AS (
    SELECT
        current_setting('autovacuum_vacuum_threshold')::numeric AS autovacuum_vacuum_threshold,
        current_setting('autovacuum_vacuum_scale_factor')::numeric AS autovacuum_vacuum_scale_factor
),
scored AS (
    SELECT
        t.*,
        round(100.0 * t.n_dead_tup / NULLIF(t.n_live_tup + t.n_dead_tup, 0), 2) AS dead_tuple_pct,
        (t.n_dead_tup * (t.total_bytes / NULLIF(t.n_live_tup + t.n_dead_tup, 0)))::bigint AS est_dead_tuple_bytes,
        (s.autovacuum_vacuum_threshold + s.autovacuum_vacuum_scale_factor * t.n_live_tup)::bigint AS estimated_autovacuum_trigger_tuples
    FROM table_stats t
    CROSS JOIN settings s
)
SELECT
    schema_name,
    table_name,
    pg_size_pretty(total_bytes) AS total_size,
    n_live_tup,
    n_dead_tup,
    dead_tuple_pct,
    est_dead_tuple_bytes,
    pg_size_pretty(est_dead_tuple_bytes) AS est_dead_tuple_space,
    estimated_autovacuum_trigger_tuples,
    n_dead_tup - estimated_autovacuum_trigger_tuples AS tuples_over_autovacuum_trigger,
    seq_scan,
    idx_scan,
    n_tup_ins,
    n_tup_upd,
    n_tup_del,
    n_tup_hot_upd,
    vacuum_count,
    autovacuum_count,
    last_vacuum,
    last_autovacuum,
    autovacuum_disabled,
    CASE
        WHEN autovacuum_disabled AND n_dead_tup > estimated_autovacuum_trigger_tuples
            THEN 'HIGH'
        WHEN n_dead_tup >= 10000000
             OR (
                 dead_tuple_pct >= 30
                 AND total_bytes >= 1024::bigint * 1024 * 1024
             )
            THEN 'CRITICAL'
        WHEN n_dead_tup >= 1000000
             OR (
                 dead_tuple_pct >= 20
                 AND total_bytes >= 256::bigint * 1024 * 1024
             )
            THEN 'HIGH'
        WHEN n_dead_tup >= 100000
             OR (
                 dead_tuple_pct >= 10
                 AND total_bytes >= 64::bigint * 1024 * 1024
             )
            THEN 'MEDIUM'
        ELSE 'LOW'
    END AS dead_tuple_severity,
    CASE
        WHEN autovacuum_disabled AND n_dead_tup > estimated_autovacuum_trigger_tuples
            THEN 'Autovacuum is disabled for this table and dead tuples are above the estimated cleanup trigger. Manual cleanup or table-level setting review is needed.'
        WHEN n_dead_tup > estimated_autovacuum_trigger_tuples
            THEN 'Dead tuples are above the estimated autovacuum trigger. Autovacuum should run unless disabled, blocked, throttled, or already behind.'
        WHEN n_dead_tup > 0 AND autovacuum_count = 0 AND vacuum_count = 0
            THEN 'Dead tuples exist but no vacuum history is visible since stats reset. Confirm autovacuum is enabled and table settings are not too relaxed.'
        WHEN last_autovacuum IS NULL AND last_vacuum IS NULL
            THEN 'No vacuum timestamp visible since stats reset. Watch this table if DML continues.'
        ELSE 'Dead tuples are visible but not clearly above the default trigger. Monitor trend and workload.'
    END AS why_it_matters,
    CASE
        WHEN autovacuum_disabled AND n_dead_tup > estimated_autovacuum_trigger_tuples
            THEN 'Immediate table review: autovacuum is disabled. Re-enable it if appropriate or schedule manual VACUUM and investigate why it was disabled.'
        WHEN n_dead_tup >= 10000000
             OR (
                 dead_tuple_pct >= 30
                 AND total_bytes >= 1024::bigint * 1024 * 1024
             )
            THEN 'Immediate action: check long transactions/backend_xmin blockers, run VACUUM during a safe window, and review per-table autovacuum settings.'
        WHEN n_dead_tup > estimated_autovacuum_trigger_tuples
            THEN 'Investigate why autovacuum has not cleaned up: blockers, cost delay, worker saturation, disabled table autovacuum, or stale statistics.'
        WHEN dead_tuple_pct >= 10
            THEN 'Monitor closely and consider manual VACUUM if the table is latency critical or update/delete heavy.'
        ELSE 'No immediate action; keep routine autovacuum monitoring and trend dead tuple growth.'
    END AS recommended_action,
    array_to_string(reloptions, ', ') AS table_storage_options
FROM scored
WHERE n_dead_tup > 0
ORDER BY
    CASE
        WHEN autovacuum_disabled AND n_dead_tup > estimated_autovacuum_trigger_tuples
            THEN 2
        WHEN n_dead_tup >= 10000000
             OR (
                 dead_tuple_pct >= 30
                 AND total_bytes >= 1024::bigint * 1024 * 1024
             )
            THEN 1
        WHEN n_dead_tup >= 1000000
             OR (
                 dead_tuple_pct >= 20
                 AND total_bytes >= 256::bigint * 1024 * 1024
             )
            THEN 2
        WHEN n_dead_tup >= 100000
             OR (
                 dead_tuple_pct >= 10
                 AND total_bytes >= 64::bigint * 1024 * 1024
             )
            THEN 3
        ELSE 4
    END,
    n_dead_tup DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name | table_name       | total_size | n_live_tup | n_dead_tup | dead_tuple_pct | est_dead_tuple_space | autovacuum_disabled | dead_tuple_severity | why_it_matters                                      | recommended_action
-- -------------+------------------+------------+------------+------------+----------------+----------------------+---------------------+---------------------+-----------------------------------------------------+------------------------------
--  public      | pgbench_accounts | 30 GB      |  200000029 |    4232485 |           2.07 | 626 MB               | f                   | HIGH                | Dead tuples are above the estimated trigger...      | Investigate why autovacuum...
--  public      | hot_churn_table  | 17 MB      |     148572 |      51428 |          25.71 | 4420 kB              | t                   | HIGH                | Autovacuum is disabled for this table...            | Immediate table review...
-- (2 rows)
-- 
-- SAMPLE_OUTPUT_END
