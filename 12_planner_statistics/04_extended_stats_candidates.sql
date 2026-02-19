/*
Purpose: Heuristically flag wide, high-write tables lacking extended statistics objects.
Area: Planner and Statistics
Usage: Candidate list for CREATE STATISTICS (dependencies, ndistinct, mcv).
*/
WITH table_profile AS (
    SELECT
        c.oid AS relid,
        n.nspname AS schema_name,
        c.relname AS table_name,
        count(a.attnum) FILTER (WHERE a.attnum > 0 AND NOT a.attisdropped) AS column_count,
        coalesce(s.n_tup_ins + s.n_tup_upd + s.n_tup_del, 0) AS write_volume,
        pg_total_relation_size(c.oid) AS total_bytes
    FROM pg_class c
    JOIN pg_namespace n
        ON n.oid = c.relnamespace
    JOIN pg_attribute a
        ON a.attrelid = c.oid
    LEFT JOIN pg_stat_user_tables s
        ON s.relid = c.oid
    WHERE c.relkind = 'r'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
    GROUP BY c.oid, n.nspname, c.relname, s.n_tup_ins, s.n_tup_upd, s.n_tup_del
),
ext_stats AS (
    SELECT stxrelid AS relid, count(*) AS ext_stats_count
    FROM pg_statistic_ext
    GROUP BY stxrelid
)
SELECT
    t.schema_name,
    t.table_name,
    t.column_count,
    t.write_volume,
    t.total_bytes,
    pg_size_pretty(t.total_bytes) AS total_pretty,
    coalesce(e.ext_stats_count, 0) AS ext_stats_count,
    CASE
        WHEN t.column_count >= 15 AND t.write_volume >= 100000 AND coalesce(e.ext_stats_count, 0) = 0 THEN 'Candidate'
        WHEN t.column_count >= 25 AND coalesce(e.ext_stats_count, 0) = 0 THEN 'Candidate'
        ELSE 'Observe'
    END AS recommendation
FROM table_profile t
LEFT JOIN ext_stats e
    ON e.relid = t.relid
ORDER BY t.total_bytes DESC;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    |       table_name        | column_count | write_volume | total_bytes | total_pretty | ext_stats_count | recommendation 
------------------+-------------------------+--------------+--------------+-------------+--------------+-----------------+----------------
 perf             | order_items             |            6 |            0 |   122626048 | 117 MB       |               0 | Observe
 perf             | app_events              |            6 |            0 |    99270656 | 95 MB        |               0 | Observe
 perf             | payments                |            7 |            0 |    87080960 | 83 MB        |               0 | Observe
 perf             | orders                  |            6 |            0 |    78512128 | 75 MB        |               0 | Observe
 perf             | shipments               |            6 |            0 |    19038208 | 18 MB        |               0 | Observe
 migration_v1_lab | child_transactions      |            4 |       120000 |    11051008 | 11 MB        |               0 | Observe
 migration_v1_lab | stale_stats_table       |            2 |        60000 |     7954432 | 7768 kB      |               0 | Observe
 migration_v1_lab | product_catalog         |            5 |        50000 |     6176768 | 6032 kB      |               0 | Observe
 perf             | users                   |            5 |            0 |     4833280 | 4720 kB      |               0 | Observe
 public           | demo_users              |            2 |            0 |     4505600 | 4400 kB      |               0 | Observe
 migration_v1_lab | dml_bloat_table         |            2 |        38000 |     4349952 | 4248 kB      |               0 | Observe
 perf             | inventory               |            4 |            0 |     3497984 | 3416 kB      |               0 | Observe
 perf             | product_categories      |            3 |            0 |     2703360 | 2640 kB      |               0 | Observe
 perf             | products                |            5 |            0 |     2285568 | 2232 kB      |               0 | Observe
 perf             | addresses               |            7 |            0 |     1613824 | 1576 kB      |               0 | Observe
 perf             | sessions                |            5 |            0 |     1376256 | 1344 kB      |               0 | Observe
 migration_v1_lab | orders_no_pk            |            3 |        10000 |      892928 | 872 kB       |               0 | Observe
 migration_v1_lab | parent_accounts         |            2 |        10000 |      811008 | 792 kB       |               0 | Observe
 migration_v1_lab | sales_orders            |            2 |         1000 |      131072 | 128 kB       |               0 | Observe
 perf             | feature_flags           |            3 |            0 |      122880 | 120 kB       |               0 | Observe
 perf             | categories              |            3 |            0 |       98304 | 96 kB        |               0 | Observe
 dba_metrics      | index_size_snapshots    |            6 |          222 |       57344 | 56 kB        |               0 | Observe
 dba_metrics      | table_size_snapshots    |            6 |          176 |       49152 | 48 kB        |               0 | Observe
 perf             | tenants                 |            3 |            0 |       32768 | 32 kB        |               0 | Observe
 perf             | documents               |            6 |            0 |       24576 | 24 kB        |               0 | Observe
 perf             | audit_log               |            8 |            0 |       24576 | 24 kB        |               0 | Observe
 perf             | job_runs                |            7 |            0 |       16384 | 16 kB        |               0 | Observe
 perf             | ticket_comments         |            6 |            0 |       16384 | 16 kB        |               0 | Observe
 dba_metrics      | connection_snapshots    |            6 |           30 |       16384 | 16 kB        |               0 | Observe
 perf             | support_tickets         |            6 |            0 |       16384 | 16 kB        |               0 | Observe
 perf             | notifications           |            6 |            0 |       16384 | 16 kB        |               0 | Observe
 dba_metrics      | wal_snapshots           |            5 |            6 |       16384 | 16 kB        |               0 | Observe
 perf             | jobs                    |            6 |            0 |       16384 | 16 kB        |               0 | Observe
 dba_metrics      | database_size_snapshots |            3 |           42 |       16384 | 16 kB        |               0 | Observe
(34 rows)


SAMPLE_OUTPUT_END */
