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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    |       table_name        | relfrozenxid | relfrozenxid_age | relminmxid | relminmxid_age | relpages | reltuples | total_size 
------------------+-------------------------+--------------+------------------+------------+----------------+----------+-----------+------------
 perf             | tenants                 |          765 |          5333457 |          1 |              0 |        0 |        -1 | 32 kB
 perf             | audit_log               |          775 |          5333447 |          1 |              0 |        0 |        -1 | 24 kB
 perf             | documents               |          776 |          5333446 |          1 |              0 |        0 |        -1 | 24 kB
 perf             | support_tickets         |          781 |          5333441 |          1 |              0 |        0 |        -1 | 16 kB
 perf             | ticket_comments         |          782 |          5333440 |          1 |              0 |        0 |        -1 | 16 kB
 perf             | notifications           |          783 |          5333439 |          1 |              0 |        0 |        -1 | 16 kB
 perf             | jobs                    |          784 |          5333438 |          1 |              0 |        0 |        -1 | 16 kB
 perf             | job_runs                |          785 |          5333437 |          1 |              0 |        0 |        -1 | 16 kB
 perf             | users                   |          801 |          5333421 |          1 |              0 |        0 |         0 | 4720 kB
 perf             | products                |          802 |          5333420 |          1 |              0 |        0 |         0 | 2232 kB
 perf             | payments                |          803 |          5333419 |          1 |              0 |        0 |         0 | 83 MB
 perf             | categories              |          804 |          5333418 |          1 |              0 |        0 |         0 | 96 kB
 perf             | product_categories      |          805 |          5333417 |          1 |              0 |        0 |         0 | 2640 kB
 perf             | orders                  |          806 |          5333416 |          1 |              0 |        0 |         0 | 75 MB
 perf             | order_items             |          806 |          5333416 |          1 |              0 |        0 |         0 | 117 MB
 perf             | shipments               |          807 |          5333415 |          1 |              0 |        0 |         0 | 18 MB
 perf             | addresses               |          808 |          5333414 |          1 |              0 |        0 |         0 | 1576 kB
 perf             | app_events              |          808 |          5333414 |          1 |              0 |        0 |         0 | 95 MB
 perf             | sessions                |          809 |          5333413 |          1 |              0 |        0 |         0 | 1344 kB
 perf             | feature_flags           |          810 |          5333412 |          1 |              0 |        0 |         0 | 120 kB
 perf             | inventory               |          811 |          5333411 |          1 |              0 |        0 |         0 | 3416 kB
 public           | demo_users              |          829 |          5333393 |          1 |              0 |      271 |     50000 | 4400 kB
 dba_metrics      | database_size_snapshots |      5333807 |              415 |          1 |              0 |        0 |        -1 | 16 kB
 dba_metrics      | table_size_snapshots    |      5333808 |              414 |          1 |              0 |        2 |       142 | 56 kB
 dba_metrics      | index_size_snapshots    |      5333809 |              413 |          1 |              0 |        3 |       222 | 64 kB
 dba_metrics      | connection_snapshots    |      5333810 |              412 |          1 |              0 |        0 |        -1 | 16 kB
 dba_metrics      | wal_snapshots           |      5333811 |              411 |          1 |              0 |        0 |        -1 | 16 kB
 migration_v1_lab | orders_no_pk            |      5334173 |               49 |          1 |              0 |       74 |     10000 | 872 kB
 migration_v1_lab | parent_accounts         |      5334178 |               44 |          1 |              0 |       64 |     10000 | 792 kB
 migration_v1_lab | child_transactions      |      5334179 |               43 |          1 |              0 |      883 |    120000 | 11 MB
 migration_v1_lab | product_catalog         |      5334181 |               41 |          1 |              0 |      417 |     50000 | 6032 kB
 migration_v1_lab | sales_orders            |      5334184 |               38 |          1 |              0 |        7 |      1000 | 128 kB
 migration_v1_lab | stale_stats_table       |      5334188 |               34 |          1 |              0 |      800 |     60000 | 7768 kB
 migration_v1_lab | dml_bloat_table         |      5334191 |               31 |          1 |              0 |      455 |     12000 | 4248 kB
(34 rows)


SAMPLE_OUTPUT_END */
