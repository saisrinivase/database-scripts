/*
Purpose: Heuristically flag large, high-write tables as partitioning candidates.
Area: Partitioning
Usage: Adjust thresholds to match your workload profile.
*/
WITH base AS (
    SELECT
        s.relid,
        s.schemaname AS schema_name,
        s.relname AS table_name,
        pg_total_relation_size(s.relid) AS total_bytes,
        s.n_live_tup AS estimated_live_rows,
        (s.n_tup_ins + s.n_tup_upd + s.n_tup_del) AS write_volume,
        c.relispartition
    FROM pg_stat_user_tables s
    JOIN pg_class c
        ON c.oid = s.relid
)
SELECT
    schema_name,
    table_name,
    total_bytes,
    pg_size_pretty(total_bytes) AS total_pretty,
    estimated_live_rows,
    write_volume,
    CASE
        WHEN total_bytes >= 50::bigint * 1024 * 1024 * 1024 AND write_volume >= 5000000
            THEN 'Strong candidate'
        WHEN total_bytes >= 20::bigint * 1024 * 1024 * 1024 AND write_volume >= 1000000
            THEN 'Candidate'
        WHEN total_bytes >= 10::bigint * 1024 * 1024 * 1024
            THEN 'Size-only candidate'
        ELSE 'Low priority'
    END AS recommendation
FROM base
WHERE NOT relispartition
ORDER BY total_bytes DESC;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    |       table_name        | total_bytes | total_pretty | estimated_live_rows | write_volume | recommendation 
------------------+-------------------------+-------------+--------------+---------------------+--------------+----------------
 perf             | order_items             |   122626048 | 117 MB       |                   0 |            0 | Low priority
 perf             | app_events              |    99270656 | 95 MB        |                   0 |            0 | Low priority
 perf             | payments                |    87080960 | 83 MB        |                   0 |            0 | Low priority
 perf             | orders                  |    78512128 | 75 MB        |                   0 |            0 | Low priority
 perf             | shipments               |    19038208 | 18 MB        |                   0 |            0 | Low priority
 migration_v1_lab | child_transactions      |    11051008 | 11 MB        |              120000 |       120000 | Low priority
 migration_v1_lab | stale_stats_table       |     7954432 | 7768 kB      |               60000 |        60000 | Low priority
 migration_v1_lab | product_catalog         |     6176768 | 6032 kB      |               50000 |        50000 | Low priority
 perf             | users                   |     4833280 | 4720 kB      |                   0 |            0 | Low priority
 public           | demo_users              |     4505600 | 4400 kB      |                   0 |            0 | Low priority
 migration_v1_lab | dml_bloat_table         |     4349952 | 4248 kB      |               12000 |        38000 | Low priority
 perf             | inventory               |     3497984 | 3416 kB      |                   0 |            0 | Low priority
 perf             | product_categories      |     2703360 | 2640 kB      |                   0 |            0 | Low priority
 perf             | products                |     2285568 | 2232 kB      |                   0 |            0 | Low priority
 perf             | addresses               |     1613824 | 1576 kB      |                   0 |            0 | Low priority
 perf             | sessions                |     1376256 | 1344 kB      |                   0 |            0 | Low priority
 migration_v1_lab | orders_no_pk            |      892928 | 872 kB       |               10000 |        10000 | Low priority
 migration_v1_lab | parent_accounts         |      811008 | 792 kB       |               10000 |        10000 | Low priority
 migration_v1_lab | sales_orders            |      131072 | 128 kB       |                1000 |         1000 | Low priority
 perf             | feature_flags           |      122880 | 120 kB       |                   0 |            0 | Low priority
 perf             | categories              |       98304 | 96 kB        |                   0 |            0 | Low priority
 dba_metrics      | index_size_snapshots    |       57344 | 56 kB        |                 222 |          222 | Low priority
 dba_metrics      | table_size_snapshots    |       49152 | 48 kB        |                 176 |          176 | Low priority
 perf             | tenants                 |       32768 | 32 kB        |                   0 |            0 | Low priority
 perf             | documents               |       24576 | 24 kB        |                   0 |            0 | Low priority
 perf             | audit_log               |       24576 | 24 kB        |                   0 |            0 | Low priority
 dba_metrics      | wal_snapshots           |       16384 | 16 kB        |                   6 |            6 | Low priority
 perf             | job_runs                |       16384 | 16 kB        |                   0 |            0 | Low priority
 perf             | jobs                    |       16384 | 16 kB        |                   0 |            0 | Low priority
 dba_metrics      | connection_snapshots    |       16384 | 16 kB        |                  30 |           30 | Low priority
 perf             | ticket_comments         |       16384 | 16 kB        |                   0 |            0 | Low priority
 perf             | support_tickets         |       16384 | 16 kB        |                   0 |            0 | Low priority
 perf             | notifications           |       16384 | 16 kB        |                   0 |            0 | Low priority
 dba_metrics      | database_size_snapshots |       16384 | 16 kB        |                  42 |           42 | Low priority
(34 rows)


SAMPLE_OUTPUT_END */
