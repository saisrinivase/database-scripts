/*
PostgreSQL DBA Script: Autovacuum Worker Pressure
Purpose: Measure autovacuum worker saturation and table backlog pressure.
Area: Background Processes and Memory Pressure
Usage: Investigate when bloat/dead tuples rise or CPU stays high.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH worker AS (
    SELECT
        count(*) FILTER (WHERE backend_type = 'autovacuum worker') AS active_autovacuum_workers,
        current_setting('autovacuum_max_workers')::int AS autovacuum_max_workers
    FROM pg_stat_activity
),
table_risk AS (
    SELECT
        s.schemaname,
        s.relname,
        s.n_live_tup,
        s.n_dead_tup,
        round(
            CASE WHEN s.n_live_tup = 0 THEN 0
                 ELSE 100.0 * s.n_dead_tup::numeric / s.n_live_tup
            END,
            2
        ) AS dead_tuple_pct,
        s.last_vacuum,
        s.last_autovacuum,
        s.vacuum_count,
        s.autovacuum_count
    FROM pg_stat_user_tables s
)
SELECT
    w.active_autovacuum_workers,
    w.autovacuum_max_workers,
    round(
        CASE WHEN w.autovacuum_max_workers = 0 THEN 0
             ELSE 100.0 * w.active_autovacuum_workers::numeric / w.autovacuum_max_workers
        END,
        2
    ) AS worker_utilization_pct,
    t.schemaname,
    t.relname,
    t.n_live_tup,
    t.n_dead_tup,
    t.dead_tuple_pct,
    t.last_vacuum,
    t.last_autovacuum,
    t.vacuum_count,
    t.autovacuum_count,
    CASE
        WHEN t.dead_tuple_pct >= 20 THEN 'HIGH_DEAD_TUPLE_PRESSURE'
        WHEN t.dead_tuple_pct >= 5 THEN 'MODERATE_DEAD_TUPLE_PRESSURE'
        ELSE 'LOW_DEAD_TUPLE_PRESSURE'
    END AS table_pressure_label
FROM worker w
CROSS JOIN LATERAL (
    SELECT *
    FROM table_risk
    ORDER BY dead_tuple_pct DESC, n_dead_tup DESC
    LIMIT 40
) t
ORDER BY t.dead_tuple_pct DESC, t.n_dead_tup DESC;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  active_autovacuum_workers | autovacuum_max_workers | worker_utilization_pct |    schemaname    |            relname            | n_live_tup | n_dead_tup | dead_tuple_pct |          last_vacuum          |        last_autovacuum        | vacuum_count | autovacuum_count |  table_pressure_label   
-- ---------------------------+------------------------+------------------------+------------------+-------------------------------+------------+------------+----------------+-------------------------------+-------------------------------+--------------+------------------+-------------------------
--                          0 |                      3 |                   0.00 | public           | pgbench_branches              |       2000 |         81 |           4.05 | 2026-02-19 09:01:04.22923-05  | 2026-02-19 09:01:38.0321-05   |           16 |               26 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | public           | pgbench_accounts              |  200000029 |    5227613 |           2.61 | 2026-01-31 21:17:24.785585-05 |                               |            1 |                0 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | sales_catalog                 |     120000 |          0 |           0.00 |                               | 2026-02-18 19:44:48.443285-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | amount_mapping_risk           |     120000 |          0 |           0.00 |                               | 2026-02-18 19:44:50.919524-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | dba_metrics      | database_size_snapshots       |         21 |          0 |           0.00 |                               |                               |            0 |                0 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | dba_metrics      | connection_snapshots          |          9 |          0 |           0.00 |                               |                               |            0 |                0 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | customer_contact_compat       |      90000 |          0 |           0.00 |                               | 2026-02-18 19:44:48.617644-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | order_fact                    |     300000 |          0 |           0.00 |                               | 2026-02-18 19:44:51.25306-05  |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | quoted_orders                 |       5000 |          0 |           0.00 |                               | 2026-02-18 19:44:48.444702-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | mv_daily_order_volume         |          1 |          0 |           0.00 |                               |                               |            0 |                0 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | trigger_audit_demo            |          0 |          0 |           0.00 |                               |                               |            0 |                0 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | stale_stats_table             |     180000 |          0 |           0.00 |                               | 2026-02-18 19:44:50.642912-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | dba_metrics      | wal_snapshots                 |          3 |          0 |           0.00 |                               |                               |            0 |                0 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v1_lab | product_catalog               |      50000 |          0 |           0.00 |                               | 2026-02-18 19:44:46.378863-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | parent_accounts               |      50000 |          0 |           0.00 |                               | 2026-02-18 19:44:47.750979-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | dba_metrics      | index_size_snapshots          |         81 |          0 |           0.00 |                               |                               |            0 |                0 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | public           | pgbench_history               |     189339 |          0 |           0.00 | 2026-01-31 21:17:26.345526-05 | 2026-02-19 09:01:39.835158-05 |            1 |               19 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v1_lab | sales_orders                  |       1000 |          0 |           0.00 |                               |                               |            0 |                0 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | partition_lab    | fact_events_10y_unpartitioned |    4500006 |          0 |           0.00 |                               | 2026-02-18 20:14:24.869944-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v1_lab | child_transactions            |     120000 |          0 |           0.00 |                               | 2026-02-18 19:44:46.033641-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | partitioned_events_2026       |      47806 |          0 |           0.00 |                               | 2026-02-18 19:44:50.956299-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | bloat_pressure_table          |      42000 |          0 |           0.00 | 2026-02-18 19:44:35.57264-05  |                               |            1 |                0 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v1_lab | parent_accounts               |      10000 |          0 |           0.00 |                               | 2026-02-18 19:44:45.276004-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | customer_staging_no_pk        |      60000 |          0 |           0.00 |                               | 2026-02-18 19:44:47.426237-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | issue_manifest                |         11 |          0 |           0.00 |                               |                               |            0 |                0 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v1_lab | stale_stats_table             |      60000 |          0 |           0.00 |                               | 2026-02-18 19:44:47.076659-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | partitioned_events            |          0 |          0 |           0.00 |                               |                               |            0 |                0 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v1_lab | dml_bloat_table               |      12000 |          0 |           0.00 | 2026-02-18 19:44:29.984588-05 |                               |            1 |                0 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | public           | pgbench_tellers               |      20000 |          0 |           0.00 | 2026-02-19 09:01:04.229787-05 | 2026-02-19 09:01:38.193994-05 |           16 |               26 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | dba_metrics      | table_size_snapshots          |         89 |          0 |           0.00 |                               |                               |            0 |                0 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v1_lab | orders_no_pk                  |      10000 |          0 |           0.00 |                               | 2026-02-18 19:44:45.219955-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | child_events                  |     250000 |          0 |           0.00 |                               | 2026-02-18 19:44:48.353211-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
--                          0 |                      3 |                   0.00 | migration_v2_lab | partitioned_events_2025       |      52194 |          0 |           0.00 |                               | 2026-02-18 19:44:51.291406-05 |            0 |                1 | LOW_DEAD_TUPLE_PRESSURE
-- (33 rows)
-- 
-- SAMPLE_OUTPUT_END
