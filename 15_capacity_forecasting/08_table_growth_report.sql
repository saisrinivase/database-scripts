/*
Purpose: Report top table growth between first and latest repository snapshots.
Area: Capacity Forecasting
Usage: Requires captured data in dba_metrics.table_size_snapshots.
*/
WITH ranked AS (
    SELECT
        schema_name,
        table_name,
        captured_at,
        total_bytes,
        row_number() OVER (PARTITION BY schema_name, table_name ORDER BY captured_at ASC) AS rn_first,
        row_number() OVER (PARTITION BY schema_name, table_name ORDER BY captured_at DESC) AS rn_last
    FROM dba_metrics.table_size_snapshots
),
first_snap AS (
    SELECT schema_name, table_name, captured_at AS first_captured_at, total_bytes AS first_bytes
    FROM ranked
    WHERE rn_first = 1
),
last_snap AS (
    SELECT schema_name, table_name, captured_at AS last_captured_at, total_bytes AS last_bytes
    FROM ranked
    WHERE rn_last = 1
)
SELECT
    l.schema_name,
    l.table_name,
    f.first_captured_at,
    l.last_captured_at,
    f.first_bytes,
    l.last_bytes,
    (l.last_bytes - f.first_bytes) AS growth_bytes,
    pg_size_pretty((l.last_bytes - f.first_bytes)::bigint) AS growth_pretty
FROM last_snap l
JOIN first_snap f
    ON f.schema_name = l.schema_name
   AND f.table_name = l.table_name
ORDER BY growth_bytes DESC
LIMIT 200;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    |       table_name        |       first_captured_at       |       last_captured_at        | first_bytes | last_bytes | growth_bytes | growth_pretty 
------------------+-------------------------+-------------------------------+-------------------------------+-------------+------------+--------------+---------------
 dba_metrics      | index_size_snapshots    | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |        8192 |      57344 |        49152 | 48 kB
 dba_metrics      | table_size_snapshots    | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |       16384 |      49152 |        32768 | 32 kB
 dba_metrics      | wal_snapshots           | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |        8192 |      16384 |         8192 | 8192 bytes
 dba_metrics      | connection_snapshots    | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |        8192 |      16384 |         8192 | 8192 bytes
 migration_v1_lab | orders_no_pk            | 2026-02-18 17:37:36.000593-05 | 2026-02-18 17:43:13.241909-05 |      892928 |     892928 |            0 | 0 bytes
 migration_v1_lab | parent_accounts         | 2026-02-18 17:37:36.000593-05 | 2026-02-18 17:43:13.241909-05 |      811008 |     811008 |            0 | 0 bytes
 migration_v1_lab | product_catalog         | 2026-02-18 17:37:36.000593-05 | 2026-02-18 17:43:13.241909-05 |     6176768 |    6176768 |            0 | 0 bytes
 migration_v1_lab | sales_orders            | 2026-02-18 17:37:36.000593-05 | 2026-02-18 17:43:13.241909-05 |      131072 |     131072 |            0 | 0 bytes
 migration_v1_lab | stale_stats_table       | 2026-02-18 17:37:36.000593-05 | 2026-02-18 17:43:13.241909-05 |     7954432 |    7954432 |            0 | 0 bytes
 perf             | addresses               | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |     1613824 |    1613824 |            0 | 0 bytes
 perf             | app_events              | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |    99270656 |   99270656 |            0 | 0 bytes
 perf             | audit_log               | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |       24576 |      24576 |            0 | 0 bytes
 perf             | categories              | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |       98304 |      98304 |            0 | 0 bytes
 perf             | documents               | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |       24576 |      24576 |            0 | 0 bytes
 perf             | feature_flags           | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |      122880 |     122880 |            0 | 0 bytes
 perf             | inventory               | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |     3497984 |    3497984 |            0 | 0 bytes
 perf             | job_runs                | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |       16384 |      16384 |            0 | 0 bytes
 perf             | jobs                    | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |       16384 |      16384 |            0 | 0 bytes
 perf             | notifications           | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |       16384 |      16384 |            0 | 0 bytes
 perf             | order_items             | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |   122626048 |  122626048 |            0 | 0 bytes
 perf             | orders                  | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |    78512128 |   78512128 |            0 | 0 bytes
 perf             | payments                | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |    87080960 |   87080960 |            0 | 0 bytes
 perf             | product_categories      | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |     2703360 |    2703360 |            0 | 0 bytes
 perf             | products                | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |     2285568 |    2285568 |            0 | 0 bytes
 perf             | sessions                | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |     1376256 |    1376256 |            0 | 0 bytes
 perf             | shipments               | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |    19038208 |   19038208 |            0 | 0 bytes
 perf             | support_tickets         | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |       16384 |      16384 |            0 | 0 bytes
 perf             | tenants                 | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |       32768 |      32768 |            0 | 0 bytes
 perf             | ticket_comments         | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |       16384 |      16384 |            0 | 0 bytes
 perf             | users                   | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |     4833280 |    4833280 |            0 | 0 bytes
 public           | demo_users              | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |     4505600 |    4505600 |            0 | 0 bytes
 dba_metrics      | database_size_snapshots | 2026-02-18 17:28:41.847294-05 | 2026-02-18 17:43:13.241909-05 |       16384 |      16384 |            0 | 0 bytes
 migration_v1_lab | child_transactions      | 2026-02-18 17:37:36.000593-05 | 2026-02-18 17:43:13.241909-05 |    11051008 |   11051008 |            0 | 0 bytes
 migration_v1_lab | dml_bloat_table         | 2026-02-18 17:37:36.000593-05 | 2026-02-18 17:43:13.241909-05 |     4349952 |    4349952 |            0 | 0 bytes
(34 rows)


SAMPLE_OUTPUT_END */
