/*
Purpose: Surface XID/multixact age and vacuum staleness risks that can lead to integrity incidents.
Area: Consistency and Integrity Checks
Usage: Treat high-age/high-dead-tuple rows as urgent maintenance candidates.
*/
WITH risk AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS table_name,
        age(c.relfrozenxid) AS xid_age,
        mxid_age(c.relminmxid) AS multixact_age,
        c.relpages,
        c.reltuples,
        s.n_live_tup,
        s.n_dead_tup,
        s.last_vacuum,
        s.last_autovacuum,
        s.vacuum_count,
        s.autovacuum_count,
        round(
            CASE WHEN coalesce(s.n_live_tup, 0) = 0 THEN 0
                 ELSE 100.0 * s.n_dead_tup::numeric / s.n_live_tup
            END,
            2
        ) AS dead_tuple_pct
    FROM pg_class c
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    LEFT JOIN pg_stat_user_tables s
      ON s.relid = c.oid
    WHERE c.relkind IN ('r', 'm', 'p')
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
)
SELECT
    schema_name,
    table_name,
    xid_age,
    multixact_age,
    relpages,
    reltuples,
    n_live_tup,
    n_dead_tup,
    dead_tuple_pct,
    last_vacuum,
    last_autovacuum,
    vacuum_count,
    autovacuum_count,
    CASE
        WHEN xid_age >= 1500000000 OR multixact_age >= 1500000000 THEN 'CRITICAL_WRAPAROUND_RISK'
        WHEN xid_age >= 1000000000 OR multixact_age >= 1000000000 THEN 'HIGH_WRAPAROUND_RISK'
        WHEN dead_tuple_pct >= 20 THEN 'BLOAT_AND_VISIBILITY_RISK'
        ELSE 'NORMAL'
    END AS integrity_risk_label
FROM risk
ORDER BY
    CASE
        WHEN xid_age >= 1500000000 OR multixact_age >= 1500000000 THEN 1
        WHEN xid_age >= 1000000000 OR multixact_age >= 1000000000 THEN 2
        WHEN dead_tuple_pct >= 20 THEN 3
        ELSE 4
    END,
    xid_age DESC,
    multixact_age DESC,
    dead_tuple_pct DESC
LIMIT 120;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--    schema_name    |          table_name           |  xid_age   | multixact_age | relpages |   reltuples   | n_live_tup | n_dead_tup | dead_tuple_pct |          last_vacuum          |        last_autovacuum        | vacuum_count | autovacuum_count |   integrity_risk_label   
-- ------------------+-------------------------------+------------+---------------+----------+---------------+------------+------------+----------------+-------------------------------+-------------------------------+--------------+------------------+--------------------------
--  migration_v2_lab | partitioned_events            | 2147483647 |    2147483647 |       -1 |        100000 |          0 |          0 |           0.00 |                               |                               |            0 |                0 | CRITICAL_WRAPAROUND_RISK
--  public           | pgbench_accounts              |    7729194 |             0 |  3278689 | 2.0000003e+08 |  200000029 |    5227613 |           2.61 | 2026-01-31 21:17:24.785585-05 |                               |            1 |                0 | NORMAL
--  dba_metrics      | database_size_snapshots       |    2395480 |             0 |        0 |            -1 |         21 |          0 |           0.00 |                               |                               |            0 |                0 | NORMAL
--  dba_metrics      | table_size_snapshots          |    2395479 |             0 |        1 |            57 |         89 |          0 |           0.00 |                               |                               |            0 |                0 | NORMAL
--  dba_metrics      | index_size_snapshots          |    2395478 |             0 |        1 |            51 |         81 |          0 |           0.00 |                               |                               |            0 |                0 | NORMAL
--  dba_metrics      | connection_snapshots          |    2395477 |             0 |        0 |            -1 |          9 |          0 |           0.00 |                               |                               |            0 |                0 | NORMAL
--  dba_metrics      | wal_snapshots                 |    2395476 |             0 |        0 |            -1 |          3 |          0 |           0.00 |                               |                               |            0 |                0 | NORMAL
--  migration_v1_lab | orders_no_pk                  |    2395148 |             0 |       74 |         10000 |      10000 |          0 |           0.00 |                               | 2026-02-18 19:44:45.219955-05 |            0 |                1 | NORMAL
--  migration_v1_lab | parent_accounts               |    2395143 |             0 |       64 |         10000 |      10000 |          0 |           0.00 |                               | 2026-02-18 19:44:45.276004-05 |            0 |                1 | NORMAL
--  migration_v1_lab | child_transactions            |    2395142 |             0 |      883 |        120000 |     120000 |          0 |           0.00 |                               | 2026-02-18 19:44:46.033641-05 |            0 |                1 | NORMAL
--  migration_v1_lab | product_catalog               |    2395140 |             0 |      417 |         50000 |      50000 |          0 |           0.00 |                               | 2026-02-18 19:44:46.378863-05 |            0 |                1 | NORMAL
--  migration_v1_lab | sales_orders                  |    2395137 |             0 |        7 |          1000 |       1000 |          0 |           0.00 |                               |                               |            0 |                0 | NORMAL
--  migration_v1_lab | stale_stats_table             |    2395133 |             0 |      800 |         60000 |      60000 |          0 |           0.00 |                               | 2026-02-18 19:44:47.076659-05 |            0 |                1 | NORMAL
--  migration_v1_lab | dml_bloat_table               |    2395130 |             0 |      455 |         12000 |      12000 |          0 |           0.00 | 2026-02-18 19:44:29.984588-05 |                               |            1 |                0 | NORMAL
--  migration_v2_lab | issue_manifest                |    2395108 |             0 |        0 |            -1 |         11 |          0 |           0.00 |                               |                               |            0 |                0 | NORMAL
--  migration_v2_lab | customer_staging_no_pk        |    2395105 |             0 |      456 |         60000 |      60000 |          0 |           0.00 |                               | 2026-02-18 19:44:47.426237-05 |            0 |                1 | NORMAL
--  migration_v2_lab | parent_accounts               |    2395100 |             0 |      368 |         50000 |      50000 |          0 |           0.00 |                               | 2026-02-18 19:44:47.750979-05 |            0 |                1 | NORMAL
--  migration_v2_lab | child_events                  |    2395099 |             0 |     2084 |        250000 |     250000 |          0 |           0.00 |                               | 2026-02-18 19:44:48.353211-05 |            0 |                1 | NORMAL
--  migration_v2_lab | sales_catalog                 |    2395097 |             0 |     1000 |        120000 |     120000 |          0 |           0.00 |                               | 2026-02-18 19:44:48.443285-05 |            0 |                1 | NORMAL
--  migration_v2_lab | quoted_orders                 |    2395093 |             0 |       41 |          5000 |       5000 |          0 |           0.00 |                               | 2026-02-18 19:44:48.444702-05 |            0 |                1 | NORMAL
--  migration_v2_lab | stale_stats_table             |    2395090 |             0 |     2572 |        180000 |     180000 |          0 |           0.00 |                               | 2026-02-18 19:44:50.642912-05 |            0 |                1 | NORMAL
--  migration_v2_lab | bloat_pressure_table          |    2395087 |             0 |     1476 |         42000 |      42000 |          0 |           0.00 | 2026-02-18 19:44:35.57264-05  |                               |            1 |                0 | NORMAL
--  migration_v2_lab | customer_contact_compat       |    2395084 |             0 |     1098 |         90000 |      90000 |          0 |           0.00 |                               | 2026-02-18 19:44:48.617644-05 |            0 |                1 | NORMAL
--  migration_v2_lab | order_fact                    |    2395080 |             0 |     3410 |        300000 |     300000 |          0 |           0.00 |                               | 2026-02-18 19:44:51.25306-05  |            0 |                1 | NORMAL
--  migration_v2_lab | trigger_audit_demo            |    2395078 |             0 |        0 |             0 |          0 |          0 |           0.00 |                               |                               |            0 |                0 | NORMAL
--  migration_v2_lab | partitioned_events_2025       |    2395068 |             0 |      488 |         52194 |      52194 |          0 |           0.00 |                               | 2026-02-18 19:44:51.291406-05 |            0 |                1 | NORMAL
--  migration_v2_lab | partitioned_events_2026       |    2395068 |             0 |      447 |         47806 |      47806 |          0 |           0.00 |                               | 2026-02-18 19:44:50.956299-05 |            0 |                1 | NORMAL
--  migration_v2_lab | amount_mapping_risk           |    2395040 |             0 |     1790 |        120000 |     120000 |          0 |           0.00 |                               | 2026-02-18 19:44:50.919524-05 |            0 |                1 | NORMAL
--  migration_v2_lab | mv_daily_order_volume         |    2395037 |             0 |        0 |            -1 |          1 |          0 |           0.00 |                               |                               |            0 |                0 | NORMAL
--  partition_lab    | fact_events_10y_unpartitioned |    2394937 |             0 |   642858 |  4.500006e+06 |    4500006 |          0 |           0.00 |                               | 2026-02-18 20:14:24.869944-05 |            0 |                1 | NORMAL
--  public           | pgbench_tellers               |     201567 |             0 |      349 |         20000 |      20000 |          0 |           0.00 | 2026-02-19 09:01:04.229787-05 | 2026-02-19 09:01:38.193994-05 |           16 |               26 | NORMAL
--  public           | pgbench_history               |     189356 |             0 |     1220 |        189339 |     189339 |          0 |           0.00 | 2026-01-31 21:17:26.345526-05 | 2026-02-19 09:01:39.835158-05 |            1 |               19 | NORMAL
--  public           | pgbench_branches              |      17600 |             0 |      858 |          2000 |       2000 |         81 |           4.05 | 2026-02-19 09:01:04.22923-05  | 2026-02-19 09:01:38.0321-05   |           16 |               26 | NORMAL
-- (33 rows)
-- 
-- SAMPLE_OUTPUT_END
