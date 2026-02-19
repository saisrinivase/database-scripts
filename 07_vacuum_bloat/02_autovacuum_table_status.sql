/*
Purpose: Review vacuum/analyze recency and dead tuples per table.
Area: Vacuum and Bloat
Usage: Focus on large tables with stale vacuum/analyze timestamps.
*/
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    vacuum_count,
    autovacuum_count,
    analyze_count,
    autoanalyze_count
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC, n_live_tup DESC;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    |       table_name        | n_live_tup | n_dead_tup |          last_vacuum          |        last_autovacuum        |         last_analyze          |       last_autoanalyze        | vacuum_count | autovacuum_count | analyze_count | autoanalyze_count 
------------------+-------------------------+------------+------------+-------------------------------+-------------------------------+-------------------------------+-------------------------------+--------------+------------------+---------------+-------------------
 migration_v1_lab | child_transactions      |     120000 |          0 |                               | 2026-02-18 17:42:43.469258-05 | 2026-02-18 17:42:27.162721-05 |                               |            0 |                1 |             1 |                 0
 migration_v1_lab | stale_stats_table       |      60000 |          0 |                               | 2026-02-18 17:42:43.569697-05 | 2026-02-18 17:42:27.41401-05  |                               |            0 |                1 |             1 |                 0
 migration_v1_lab | product_catalog         |      50000 |          0 |                               | 2026-02-18 17:42:43.505269-05 | 2026-02-18 17:42:27.247937-05 |                               |            0 |                1 |             1 |                 0
 migration_v1_lab | dml_bloat_table         |      12000 |          0 | 2026-02-18 17:42:27.415845-05 |                               | 2026-02-18 17:42:27.4164-05   |                               |            1 |                0 |             1 |                 0
 migration_v1_lab | parent_accounts         |      10000 |          0 |                               | 2026-02-18 17:42:43.378542-05 | 2026-02-18 17:42:27.146512-05 |                               |            0 |                1 |             1 |                 0
 migration_v1_lab | orders_no_pk            |      10000 |          0 |                               | 2026-02-18 17:42:43.392012-05 | 2026-02-18 17:42:27.125352-05 |                               |            0 |                1 |             1 |                 0
 migration_v1_lab | sales_orders            |       1000 |          0 |                               |                               | 2026-02-18 17:42:27.25081-05  |                               |            0 |                0 |             1 |                 0
 dba_metrics      | index_size_snapshots    |        222 |          0 |                               |                               |                               | 2026-02-18 17:42:43.370729-05 |            0 |                0 |             0 |                 3
 dba_metrics      | table_size_snapshots    |        176 |          0 |                               |                               |                               | 2026-02-18 17:37:43.159982-05 |            0 |                0 |             0 |                 2
 dba_metrics      | database_size_snapshots |         42 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 dba_metrics      | connection_snapshots    |         30 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 dba_metrics      | wal_snapshots           |          6 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | tenants                 |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | inventory               |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | addresses               |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | job_runs                |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | products                |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | jobs                    |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | feature_flags           |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | notifications           |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | sessions                |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | shipments               |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | categories              |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | audit_log               |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | documents               |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | support_tickets         |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | orders                  |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | users                   |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | order_items             |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | payments                |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | app_events              |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | product_categories      |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 perf             | ticket_comments         |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
 public           | demo_users              |          0 |          0 |                               |                               |                               |                               |            0 |                0 |             0 |                 0
(34 rows)


SAMPLE_OUTPUT_END */
