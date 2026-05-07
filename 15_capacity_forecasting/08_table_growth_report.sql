/*
PostgreSQL DBA Script: Table Growth Report
Purpose: Report top table growth between first and latest repository snapshots.
Area: Capacity Forecasting
Usage: Requires captured data in dba_metrics.table_size_snapshots.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        |       first_captured_at       |       last_captured_at        | first_bytes | last_bytes  | growth_bytes | growth_pretty 
-- ------------------+-------------------------+-------------------------------+-------------------------------+-------------+-------------+--------------+---------------
--  dba_metrics      | index_size_snapshots    | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |        8192 |       16384 |         8192 | 8192 bytes
--  dba_metrics      | wal_snapshots           | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |        8192 |       16384 |         8192 | 8192 bytes
--  dba_metrics      | connection_snapshots    | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |        8192 |       16384 |         8192 | 8192 bytes
--  migration_v1_lab | child_transactions      | 2026-02-18 19:43:32.207569-05 | 2026-02-18 19:43:32.207569-05 |    11051008 |    11051008 |            0 | 0 bytes
--  migration_v1_lab | dml_bloat_table         | 2026-02-18 19:43:32.207569-05 | 2026-02-18 19:43:32.207569-05 |     4349952 |     4349952 |            0 | 0 bytes
--  migration_v1_lab | orders_no_pk            | 2026-02-18 19:43:32.207569-05 | 2026-02-18 19:43:32.207569-05 |      892928 |      892928 |            0 | 0 bytes
--  migration_v1_lab | parent_accounts         | 2026-02-18 19:43:32.207569-05 | 2026-02-18 19:43:32.207569-05 |      811008 |      811008 |            0 | 0 bytes
--  migration_v1_lab | product_catalog         | 2026-02-18 19:43:32.207569-05 | 2026-02-18 19:43:32.207569-05 |     6176768 |     6176768 |            0 | 0 bytes
--  migration_v1_lab | sales_orders            | 2026-02-18 19:43:32.207569-05 | 2026-02-18 19:43:32.207569-05 |      131072 |      131072 |            0 | 0 bytes
--  migration_v1_lab | stale_stats_table       | 2026-02-18 19:43:32.207569-05 | 2026-02-18 19:43:32.207569-05 |     7954432 |     7954432 |            0 | 0 bytes
--  migration_v2_lab | amount_mapping_risk     | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |    20119552 |    20119552 |            0 | 0 bytes
--  migration_v2_lab | bloat_pressure_table    | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |    14163968 |    14163968 |            0 | 0 bytes
--  migration_v2_lab | child_events            | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |    25714688 |    25714688 |            0 | 0 bytes
--  migration_v2_lab | customer_contact_compat | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |    13107200 |    13107200 |            0 | 0 bytes
--  migration_v2_lab | customer_staging_no_pk  | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |     5136384 |     5136384 |            0 | 0 bytes
--  migration_v2_lab | issue_manifest          | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |       32768 |       32768 |            0 | 0 bytes
--  migration_v2_lab | mv_daily_order_volume   | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |       24576 |       24576 |            0 | 0 bytes
--  migration_v2_lab | order_fact              | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |    51806208 |    51806208 |            0 | 0 bytes
--  migration_v2_lab | parent_accounts         | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |     4194304 |     4194304 |            0 | 0 bytes
--  migration_v2_lab | partitioned_events      | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |           0 |           0 |            0 | 0 bytes
--  migration_v2_lab | partitioned_events_2025 | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |     5693440 |     5693440 |            0 | 0 bytes
--  migration_v2_lab | partitioned_events_2026 | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |     5226496 |     5226496 |            0 | 0 bytes
--  migration_v2_lab | quoted_orders           | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |      507904 |      507904 |            0 | 0 bytes
--  migration_v2_lab | sales_catalog           | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |    14745600 |    14745600 |            0 | 0 bytes
--  migration_v2_lab | stale_stats_table       | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |    25174016 |    25174016 |            0 | 0 bytes
--  migration_v2_lab | trigger_audit_demo      | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |       16384 |       16384 |            0 | 0 bytes
--  public           | pgbench_accounts        | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 | 31716564992 | 31716564992 |            0 | 0 bytes
--  public           | pgbench_branches        | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |     7217152 |     7217152 |            0 | 0 bytes
--  public           | pgbench_history         | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |   282656768 |   282656768 |            0 | 0 bytes
--  public           | pgbench_tellers         | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |     3801088 |     3801088 |            0 | 0 bytes
--  dba_metrics      | database_size_snapshots | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |       16384 |       16384 |            0 | 0 bytes
--  dba_metrics      | table_size_snapshots    | 2026-02-18 19:39:57.48928-05  | 2026-02-18 19:43:32.207569-05 |       16384 |       16384 |            0 | 0 bytes
-- (32 rows)
-- 
-- SAMPLE_OUTPUT_END
