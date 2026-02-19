/*
Purpose: Quickly list the largest tables in the current database.
Area: Table Storage
Usage: Change LIMIT value based on reporting need.
*/
SELECT
    n.nspname AS schema_name,
    c.relname AS table_name,
    pg_total_relation_size(c.oid) AS total_bytes,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS total_pretty,
    s.n_live_tup AS estimated_live_rows,
    s.n_dead_tup AS estimated_dead_rows
FROM pg_class c
JOIN pg_namespace n
    ON n.oid = c.relnamespace
LEFT JOIN pg_stat_user_tables s
    ON s.relid = c.oid
WHERE c.relkind IN ('r', 'm')
  AND n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
ORDER BY total_bytes DESC
LIMIT 50;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    |       table_name        | total_bytes | total_pretty | estimated_live_rows | estimated_dead_rows 
------------------+-------------------------+-------------+--------------+---------------------+---------------------
 perf             | order_items             |   122626048 | 117 MB       |                   0 |                   0
 perf             | app_events              |    99270656 | 95 MB        |                   0 |                   0
 perf             | payments                |    87080960 | 83 MB        |                   0 |                   0
 perf             | orders                  |    78512128 | 75 MB        |                   0 |                   0
 perf             | shipments               |    19038208 | 18 MB        |                   0 |                   0
 migration_v1_lab | child_transactions      |    11051008 | 11 MB        |              120000 |                   0
 migration_v1_lab | stale_stats_table       |     7954432 | 7768 kB      |               60000 |                   0
 migration_v1_lab | product_catalog         |     6176768 | 6032 kB      |               50000 |                   0
 perf             | users                   |     4833280 | 4720 kB      |                   0 |                   0
 public           | demo_users              |     4505600 | 4400 kB      |                   0 |                   0
 migration_v1_lab | dml_bloat_table         |     4349952 | 4248 kB      |               12000 |                   0
 perf             | inventory               |     3497984 | 3416 kB      |                   0 |                   0
 perf             | product_categories      |     2703360 | 2640 kB      |                   0 |                   0
 perf             | products                |     2285568 | 2232 kB      |                   0 |                   0
 perf             | addresses               |     1613824 | 1576 kB      |                   0 |                   0
 perf             | sessions                |     1376256 | 1344 kB      |                   0 |                   0
 migration_v1_lab | orders_no_pk            |      892928 | 872 kB       |               10000 |                   0
 migration_v1_lab | parent_accounts         |      811008 | 792 kB       |               10000 |                   0
 migration_v1_lab | sales_orders            |      131072 | 128 kB       |                1000 |                   0
 perf             | feature_flags           |      122880 | 120 kB       |                   0 |                   0
 perf             | categories              |       98304 | 96 kB        |                   0 |                   0
 dba_metrics      | index_size_snapshots    |       57344 | 56 kB        |                 222 |                   0
 dba_metrics      | table_size_snapshots    |       49152 | 48 kB        |                 176 |                   0
 perf             | tenants                 |       32768 | 32 kB        |                   0 |                   0
 perf             | documents               |       24576 | 24 kB        |                   0 |                   0
 perf             | audit_log               |       24576 | 24 kB        |                   0 |                   0
 dba_metrics      | wal_snapshots           |       16384 | 16 kB        |                   6 |                   0
 perf             | job_runs                |       16384 | 16 kB        |                   0 |                   0
 perf             | jobs                    |       16384 | 16 kB        |                   0 |                   0
 dba_metrics      | connection_snapshots    |       16384 | 16 kB        |                  30 |                   0
 perf             | ticket_comments         |       16384 | 16 kB        |                   0 |                   0
 perf             | support_tickets         |       16384 | 16 kB        |                   0 |                   0
 perf             | notifications           |       16384 | 16 kB        |                   0 |                   0
 dba_metrics      | database_size_snapshots |       16384 | 16 kB        |                  42 |                   0
(34 rows)


SAMPLE_OUTPUT_END */
