/*
Purpose: Create table modification delta views (insert/update/delete/HOT) and monthly rollups.
Area: Object Lifecycle and Capacity Monitoring
Usage: PostgreSQL approximation for Oracle DBA_TAB_MODIFICATIONS style monitoring.
*/
CREATE SCHEMA IF NOT EXISTS dba_metrics;

CREATE OR REPLACE VIEW dba_metrics.vw_table_modification_delta AS
WITH ordered AS (
    SELECT
        s.*,
        lag(s.n_tup_ins) OVER (PARTITION BY s.table_oid ORDER BY s.captured_at) AS prev_n_tup_ins,
        lag(s.n_tup_upd) OVER (PARTITION BY s.table_oid ORDER BY s.captured_at) AS prev_n_tup_upd,
        lag(s.n_tup_del) OVER (PARTITION BY s.table_oid ORDER BY s.captured_at) AS prev_n_tup_del,
        lag(s.n_tup_hot_upd) OVER (PARTITION BY s.table_oid ORDER BY s.captured_at) AS prev_n_tup_hot_upd,
        lag(s.stats_reset) OVER (PARTITION BY s.table_oid ORDER BY s.captured_at) AS prev_stats_reset
    FROM dba_metrics.table_mod_snap s
)
SELECT
    run_id,
    captured_at,
    database_name,
    stats_reset,
    table_oid,
    schema_name,
    table_name,
    n_tup_ins,
    n_tup_upd,
    n_tup_del,
    n_tup_hot_upd,
    n_live_tup,
    n_dead_tup,
    n_mod_since_analyze,
    vacuum_count,
    autovacuum_count,
    analyze_count,
    autoanalyze_count,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    table_total_size_bytes,
    CASE
        WHEN prev_n_tup_ins IS NULL OR prev_stats_reset IS DISTINCT FROM stats_reset THEN NULL
        WHEN n_tup_ins < prev_n_tup_ins THEN NULL
        ELSE n_tup_ins - prev_n_tup_ins
    END AS delta_ins,
    CASE
        WHEN prev_n_tup_upd IS NULL OR prev_stats_reset IS DISTINCT FROM stats_reset THEN NULL
        WHEN n_tup_upd < prev_n_tup_upd THEN NULL
        ELSE n_tup_upd - prev_n_tup_upd
    END AS delta_upd,
    CASE
        WHEN prev_n_tup_del IS NULL OR prev_stats_reset IS DISTINCT FROM stats_reset THEN NULL
        WHEN n_tup_del < prev_n_tup_del THEN NULL
        ELSE n_tup_del - prev_n_tup_del
    END AS delta_del,
    CASE
        WHEN prev_n_tup_hot_upd IS NULL OR prev_stats_reset IS DISTINCT FROM stats_reset THEN NULL
        WHEN n_tup_hot_upd < prev_n_tup_hot_upd THEN NULL
        ELSE n_tup_hot_upd - prev_n_tup_hot_upd
    END AS delta_hot_upd,
    round(
        CASE
            WHEN coalesce(n_live_tup, 0) = 0 THEN 0
            ELSE 100.0 * coalesce(n_dead_tup, 0)::numeric / n_live_tup
        END,
        2
    ) AS dead_tuple_pct
FROM ordered;

CREATE OR REPLACE VIEW dba_metrics.vw_table_modifications_monthly AS
WITH base AS (
    SELECT
        date_trunc('month', captured_at)::date AS month_start,
        schema_name,
        table_name,
        max(captured_at) AS last_capture_in_month,
        sum(coalesce(delta_ins, 0)) AS inserts,
        sum(coalesce(delta_upd, 0)) AS updates,
        sum(coalesce(delta_del, 0)) AS deletes,
        sum(coalesce(delta_hot_upd, 0)) AS hot_updates,
        max(dead_tuple_pct) AS max_dead_tuple_pct,
        max(table_total_size_bytes) AS max_table_total_size_bytes
    FROM dba_metrics.vw_table_modification_delta
    GROUP BY
        date_trunc('month', captured_at)::date,
        schema_name,
        table_name
)
SELECT
    month_start,
    schema_name,
    table_name,
    inserts,
    updates,
    deletes,
    hot_updates,
    (inserts + updates + deletes) AS total_dml,
    max_dead_tuple_pct,
    max_table_total_size_bytes,
    pg_size_pretty(max_table_total_size_bytes) AS max_table_total_size_pretty,
    last_capture_in_month
FROM base;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_37_verify_20260220_safedrop_final
--
-- CREATE SCHEMA
-- CREATE VIEW
-- CREATE VIEW
-- SAMPLE_OUTPUT_END
