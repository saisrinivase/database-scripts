/*
Purpose: Capture current table size and row estimate as a growth baseline snapshot.
Area: Table Storage
Usage: Export results periodically and compare snapshots externally.
*/
SELECT
    now() AS captured_at,
    s.schemaname AS schema_name,
    s.relname AS table_name,
    s.n_live_tup AS estimated_live_rows,
    s.n_dead_tup AS estimated_dead_rows,
    pg_total_relation_size(s.relid) AS total_bytes,
    pg_size_pretty(pg_total_relation_size(s.relid)) AS total_pretty
FROM pg_stat_user_tables s
ORDER BY total_bytes DESC;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

         captured_at          |   schema_name    |       table_name        | estimated_live_rows | estimated_dead_rows | total_bytes | total_pretty 
------------------------------+------------------+-------------------------+---------------------+---------------------+-------------+--------------
 2026-02-18 17:43:11.93201-05 | perf             | order_items             |                   0 |                   0 |   122626048 | 117 MB
 2026-02-18 17:43:11.93201-05 | perf             | app_events              |                   0 |                   0 |    99270656 | 95 MB
 2026-02-18 17:43:11.93201-05 | perf             | payments                |                   0 |                   0 |    87080960 | 83 MB
 2026-02-18 17:43:11.93201-05 | perf             | orders                  |                   0 |                   0 |    78512128 | 75 MB
 2026-02-18 17:43:11.93201-05 | perf             | shipments               |                   0 |                   0 |    19038208 | 18 MB
 2026-02-18 17:43:11.93201-05 | migration_v1_lab | child_transactions      |              120000 |                   0 |    11051008 | 11 MB
 2026-02-18 17:43:11.93201-05 | migration_v1_lab | stale_stats_table       |               60000 |                   0 |     7954432 | 7768 kB
 2026-02-18 17:43:11.93201-05 | migration_v1_lab | product_catalog         |               50000 |                   0 |     6176768 | 6032 kB
 2026-02-18 17:43:11.93201-05 | perf             | users                   |                   0 |                   0 |     4833280 | 4720 kB
 2026-02-18 17:43:11.93201-05 | public           | demo_users              |                   0 |                   0 |     4505600 | 4400 kB
 2026-02-18 17:43:11.93201-05 | migration_v1_lab | dml_bloat_table         |               12000 |                   0 |     4349952 | 4248 kB
 2026-02-18 17:43:11.93201-05 | perf             | inventory               |                   0 |                   0 |     3497984 | 3416 kB
 2026-02-18 17:43:11.93201-05 | perf             | product_categories      |                   0 |                   0 |     2703360 | 2640 kB
 2026-02-18 17:43:11.93201-05 | perf             | products                |                   0 |                   0 |     2285568 | 2232 kB
 2026-02-18 17:43:11.93201-05 | perf             | addresses               |                   0 |                   0 |     1613824 | 1576 kB
 2026-02-18 17:43:11.93201-05 | perf             | sessions                |                   0 |                   0 |     1376256 | 1344 kB
 2026-02-18 17:43:11.93201-05 | migration_v1_lab | orders_no_pk            |               10000 |                   0 |      892928 | 872 kB
 2026-02-18 17:43:11.93201-05 | migration_v1_lab | parent_accounts         |               10000 |                   0 |      811008 | 792 kB
 2026-02-18 17:43:11.93201-05 | migration_v1_lab | sales_orders            |                1000 |                   0 |      131072 | 128 kB
 2026-02-18 17:43:11.93201-05 | perf             | feature_flags           |                   0 |                   0 |      122880 | 120 kB
 2026-02-18 17:43:11.93201-05 | perf             | categories              |                   0 |                   0 |       98304 | 96 kB
 2026-02-18 17:43:11.93201-05 | dba_metrics      | index_size_snapshots    |                 222 |                   0 |       57344 | 56 kB
 2026-02-18 17:43:11.93201-05 | dba_metrics      | table_size_snapshots    |                 176 |                   0 |       49152 | 48 kB
 2026-02-18 17:43:11.93201-05 | perf             | tenants                 |                   0 |                   0 |       32768 | 32 kB
 2026-02-18 17:43:11.93201-05 | perf             | documents               |                   0 |                   0 |       24576 | 24 kB
 2026-02-18 17:43:11.93201-05 | perf             | audit_log               |                   0 |                   0 |       24576 | 24 kB
 2026-02-18 17:43:11.93201-05 | perf             | notifications           |                   0 |                   0 |       16384 | 16 kB
 2026-02-18 17:43:11.93201-05 | dba_metrics      | connection_snapshots    |                  30 |                   0 |       16384 | 16 kB
 2026-02-18 17:43:11.93201-05 | dba_metrics      | wal_snapshots           |                   6 |                   0 |       16384 | 16 kB
 2026-02-18 17:43:11.93201-05 | perf             | support_tickets         |                   0 |                   0 |       16384 | 16 kB
 2026-02-18 17:43:11.93201-05 | perf             | job_runs                |                   0 |                   0 |       16384 | 16 kB
 2026-02-18 17:43:11.93201-05 | perf             | ticket_comments         |                   0 |                   0 |       16384 | 16 kB
 2026-02-18 17:43:11.93201-05 | perf             | jobs                    |                   0 |                   0 |       16384 | 16 kB
 2026-02-18 17:43:11.93201-05 | dba_metrics      | database_size_snapshots |                  42 |                   0 |       16384 | 16 kB
(34 rows)


SAMPLE_OUTPUT_END */
