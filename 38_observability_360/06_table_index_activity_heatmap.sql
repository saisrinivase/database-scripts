/*
PostgreSQL DBA Script: Table Index Activity Heatmap
Purpose: Rank tables by read/write pressure, dead tuples, sequential scans, index scans, and storage size.
Area: Observability 360
Usage: Use after the instance dashboard points to table/index, vacuum, or scan pressure.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. Statistics are cumulative since stats reset.
*/
WITH index_reads AS (
    SELECT
        schemaname,
        relname,
        sum(idx_scan) AS index_scans,
        sum(idx_tup_read) AS index_tuples_read,
        sum(idx_tup_fetch) AS index_tuples_fetched
    FROM pg_stat_user_indexes
    GROUP BY schemaname, relname
)
SELECT
    t.schemaname,
    t.relname AS table_name,
    pg_total_relation_size(format('%I.%I', t.schemaname, t.relname)::regclass) AS total_bytes,
    pg_size_pretty(pg_total_relation_size(format('%I.%I', t.schemaname, t.relname)::regclass)) AS total_size,
    t.n_live_tup,
    t.n_dead_tup,
    round(100.0 * t.n_dead_tup / NULLIF(t.n_live_tup + t.n_dead_tup, 0), 2) AS dead_tuple_pct,
    t.seq_scan,
    t.seq_tup_read,
    coalesce(i.index_scans, 0) AS index_scans,
    coalesce(i.index_tuples_read, 0) AS index_tuples_read,
    t.n_tup_ins,
    t.n_tup_upd,
    t.n_tup_del,
    t.n_tup_hot_upd,
    round(100.0 * t.n_tup_hot_upd / NULLIF(t.n_tup_upd, 0), 2) AS hot_update_pct,
    greatest(t.last_vacuum, t.last_autovacuum) AS last_vacuum_any,
    greatest(t.last_analyze, t.last_autoanalyze) AS last_analyze_any
FROM pg_stat_user_tables t
LEFT JOIN index_reads i ON i.schemaname = t.schemaname AND i.relname = t.relname
ORDER BY
    pg_total_relation_size(format('%I.%I', t.schemaname, t.relname)::regclass) DESC,
    t.n_dead_tup DESC
LIMIT 100;

-- SAMPLE_OUTPUT_BEGIN
-- schemaname | table_name | total_size | n_live_tup | n_dead_tup | dead_tuple_pct | seq_scan | index_scans | hot_update_pct
-- -----------+------------+------------+------------+------------+----------------+----------+-------------+---------------
-- public     | orders     | 42 GB      | 980000000  | 24000000   |           2.39 |     1832 |    92837411 |         71.04
-- public     | events     | 18 GB      | 310000000  | 62000000   |          16.67 |     8821 |      382911 |         12.88
-- SAMPLE_OUTPUT_END
