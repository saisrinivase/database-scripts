/*
PostgreSQL DBA Script: Extended Stats Candidates
Purpose: Heuristically flag wide, high-write tables lacking extended statistics objects.
Area: Planner and Statistics
Usage: Candidate list for CREATE STATISTICS (dependencies, ndistinct, mcv).
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |       table_name        | column_count | write_volume | total_bytes | total_pretty | ext_stats_count | recommendation 
-- ------------------+-------------------------+--------------+--------------+-------------+--------------+-----------------+----------------
--  public           | pgbench_accounts        |            4 |    205332823 | 31716564992 | 30 GB        |               0 | Observe
--  public           | pgbench_history         |            6 |      5332823 |   282656768 | 270 MB       |               0 | Observe
--  migration_v2_lab | order_fact              |            6 |       300000 |    51806208 | 49 MB        |               0 | Observe
--  migration_v2_lab | child_events            |            5 |       250000 |    25714688 | 25 MB        |               0 | Observe
--  migration_v2_lab | stale_stats_table       |            3 |       180000 |    25174016 | 24 MB        |               0 | Observe
--  migration_v2_lab | amount_mapping_risk     |            5 |       240000 |    20119552 | 19 MB        |               0 | Observe
--  migration_v2_lab | sales_catalog           |            5 |       120000 |    14745600 | 14 MB        |               0 | Observe
--  migration_v2_lab | bloat_pressure_table    |            3 |       138000 |    14163968 | 14 MB        |               0 | Observe
--  migration_v2_lab | customer_contact_compat |            4 |       141429 |    13107200 | 13 MB        |               0 | Observe
--  migration_v1_lab | child_transactions      |            4 |       120000 |    11051008 | 11 MB        |               0 | Observe
--  migration_v1_lab | stale_stats_table       |            2 |        60000 |     7954432 | 7768 kB      |               0 | Observe
--  public           | pgbench_branches        |            3 |      5334823 |     7217152 | 7048 kB      |               0 | Observe
--  migration_v1_lab | product_catalog         |            5 |        50000 |     6176768 | 6032 kB      |               0 | Observe
--  migration_v2_lab | partitioned_events_2025 |            3 |        52194 |     5693440 | 5560 kB      |               0 | Observe
--  migration_v2_lab | partitioned_events_2026 |            3 |        47806 |     5226496 | 5104 kB      |               0 | Observe
--  migration_v2_lab | customer_staging_no_pk  |            4 |        60000 |     5136384 | 5016 kB      |               0 | Observe
--  migration_v1_lab | dml_bloat_table         |            2 |        38000 |     4349952 | 4248 kB      |               0 | Observe
--  migration_v2_lab | parent_accounts         |            3 |        50000 |     4194304 | 4096 kB      |               0 | Observe
--  public           | pgbench_tellers         |            4 |      5352823 |     3801088 | 3712 kB      |               0 | Observe
--  migration_v1_lab | orders_no_pk            |            3 |        10000 |      892928 | 872 kB       |               0 | Observe
--  migration_v1_lab | parent_accounts         |            2 |        10000 |      811008 | 792 kB       |               0 | Observe
--  migration_v2_lab | quoted_orders           |            3 |         5000 |      507904 | 496 kB       |               0 | Observe
--  migration_v1_lab | sales_orders            |            2 |         1000 |      131072 | 128 kB       |               0 | Observe
--  migration_v2_lab | issue_manifest          |            4 |           11 |       32768 | 32 kB        |               0 | Observe
--  dba_metrics      | table_size_snapshots    |            6 |           25 |       16384 | 16 kB        |               0 | Observe
--  migration_v2_lab | trigger_audit_demo      |            3 |            0 |       16384 | 16 kB        |               0 | Observe
--  dba_metrics      | connection_snapshots    |            6 |            3 |       16384 | 16 kB        |               0 | Observe
--  dba_metrics      | index_size_snapshots    |            6 |           21 |       16384 | 16 kB        |               0 | Observe
--  dba_metrics      | database_size_snapshots |            3 |            7 |       16384 | 16 kB        |               0 | Observe
--  dba_metrics      | wal_snapshots           |            5 |            1 |       16384 | 16 kB        |               0 | Observe
-- (30 rows)
-- 
-- SAMPLE_OUTPUT_END
