/*
Purpose: Correlate visibility/freeze internals for table aging and maintenance planning.
Area: Internals Deep Dive
Usage: Compare with autovacuum settings and freeze thresholds.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    c.relfrozenxid,
    age(c.relfrozenxid) AS relfrozenxid_age,
    c.relminmxid,
    mxid_age(c.relminmxid) AS relminmxid_age,
    c.relpages,
    c.reltuples,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'm')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY relfrozenxid_age DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | relfrozenxid | relfrozenxid_age | relminmxid | relminmxid_age | relpages |   reltuples   | total_size 
-- ------------------+-------------------------+--------------+------------------+------------+----------------+----------+---------------+------------
--  public           | pgbench_accounts        |          878 |          5333878 |          1 |              0 |  3278689 | 2.0000003e+08 | 30 GB
--  public           | pgbench_history         |          929 |          5333827 |          1 |              0 |    34492 |   5.33113e+06 | 270 MB
--  public           | pgbench_tellers         |      5163629 |           171127 |          1 |              0 |      349 |         20000 | 3712 kB
--  public           | pgbench_branches        |      5315537 |            19219 |          1 |              0 |      858 |          2000 | 7048 kB
--  dba_metrics      | database_size_snapshots |      5334592 |              164 |          1 |              0 |        0 |            -1 | 16 kB
--  dba_metrics      | table_size_snapshots    |      5334593 |              163 |          1 |              0 |        0 |            -1 | 16 kB
--  dba_metrics      | index_size_snapshots    |      5334594 |              162 |          1 |              0 |        0 |            -1 | 16 kB
--  dba_metrics      | connection_snapshots    |      5334595 |              161 |          1 |              0 |        0 |            -1 | 16 kB
--  dba_metrics      | wal_snapshots           |      5334596 |              160 |          1 |              0 |        0 |            -1 | 16 kB
--  migration_v1_lab | orders_no_pk            |      5334610 |              146 |          1 |              0 |       74 |         10000 | 872 kB
--  migration_v1_lab | parent_accounts         |      5334615 |              141 |          1 |              0 |       64 |         10000 | 792 kB
--  migration_v1_lab | child_transactions      |      5334616 |              140 |          1 |              0 |      883 |        120000 | 11 MB
--  migration_v1_lab | product_catalog         |      5334618 |              138 |          1 |              0 |      417 |         50000 | 6032 kB
--  migration_v1_lab | sales_orders            |      5334621 |              135 |          1 |              0 |        7 |          1000 | 128 kB
--  migration_v1_lab | stale_stats_table       |      5334625 |              131 |          1 |              0 |      800 |         60000 | 7768 kB
--  migration_v1_lab | dml_bloat_table         |      5334628 |              128 |          1 |              0 |      455 |         12000 | 4248 kB
--  migration_v2_lab | issue_manifest          |      5334650 |              106 |          1 |              0 |        0 |            -1 | 32 kB
--  migration_v2_lab | customer_staging_no_pk  |      5334653 |              103 |          1 |              0 |      456 |         60000 | 5016 kB
--  migration_v2_lab | parent_accounts         |      5334658 |               98 |          1 |              0 |      368 |         50000 | 4096 kB
--  migration_v2_lab | child_events            |      5334659 |               97 |          1 |              0 |     2084 |        250000 | 25 MB
--  migration_v2_lab | sales_catalog           |      5334661 |               95 |          1 |              0 |     1000 |        120000 | 14 MB
--  migration_v2_lab | quoted_orders           |      5334665 |               91 |          1 |              0 |       41 |          5000 | 496 kB
--  migration_v2_lab | stale_stats_table       |      5334668 |               88 |          1 |              0 |     2572 |        180000 | 24 MB
--  migration_v2_lab | bloat_pressure_table    |      5334671 |               85 |          1 |              0 |     1476 |         42000 | 14 MB
--  migration_v2_lab | customer_contact_compat |      5334674 |               82 |          1 |              0 |     1098 |         90000 | 13 MB
--  migration_v2_lab | order_fact              |      5334678 |               78 |          1 |              0 |     3410 |        300000 | 49 MB
--  migration_v2_lab | trigger_audit_demo      |      5334680 |               76 |          1 |              0 |        0 |             0 | 16 kB
--  migration_v2_lab | partitioned_events_2025 |      5334690 |               66 |          1 |              0 |      488 |         52194 | 5560 kB
--  migration_v2_lab | partitioned_events_2026 |      5334690 |               66 |          1 |              0 |      447 |         47806 | 5104 kB
--  migration_v2_lab | amount_mapping_risk     |      5334718 |               38 |          1 |              0 |     1790 |        120000 | 19 MB
--  migration_v2_lab | mv_daily_order_volume   |      5334721 |               35 |          1 |              0 |        0 |            -1 | 24 kB
-- (31 rows)
-- 
-- SAMPLE_OUTPUT_END
