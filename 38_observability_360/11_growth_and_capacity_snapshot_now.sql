/*
PostgreSQL DBA Script: Growth And Capacity Snapshot Now
Purpose: Capture a current one-shot view of database size, largest relations, WAL retention, XID age, and temp usage.
Area: Observability 360
Usage: Run during capacity reviews or before enabling periodic snapshots in 15_capacity_forecasting.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only. For historical growth rates, schedule the repository scripts in 15_capacity_forecasting.
*/
SELECT
    'database_size' AS section,
    datname AS object_name,
    pg_database_size(datname) AS bytes,
    pg_size_pretty(pg_database_size(datname)) AS size_pretty,
    age(datfrozenxid)::numeric AS age_or_count,
    'database bytes and xid age' AS purpose
FROM pg_database
ORDER BY bytes DESC;

SELECT
    'largest_relations' AS section,
    n.nspname || '.' || c.relname AS object_name,
    pg_total_relation_size(c.oid) AS bytes,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS size_pretty,
    s.n_dead_tup::numeric AS age_or_count,
    'largest tables/materialized views with dead tuple estimate' AS purpose
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_stat_user_tables s ON s.relid = c.oid
WHERE c.relkind IN ('r','p','m')
  AND n.nspname NOT IN ('pg_catalog','information_schema')
ORDER BY bytes DESC
LIMIT 50;

SELECT
    'replication_slot_retained_wal' AS section,
    slot_name AS object_name,
    coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn), 0) AS bytes,
    pg_size_pretty(coalesce(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn), 0)) AS size_pretty,
    NULL::numeric AS age_or_count,
    'WAL retained by replication slot' AS purpose
FROM pg_replication_slots
ORDER BY bytes DESC NULLS LAST;

SELECT
    'database_temp_usage' AS section,
    datname AS object_name,
    temp_bytes AS bytes,
    pg_size_pretty(temp_bytes) AS size_pretty,
    temp_files::numeric AS age_or_count,
    'Cumulative temp file bytes and file count since stats reset' AS purpose
FROM pg_stat_database
WHERE datname IS NOT NULL
ORDER BY temp_bytes DESC;

-- SAMPLE_OUTPUT_BEGIN
-- section                       | object_name      | bytes       | size_pretty | age_or_count | purpose
-- ------------------------------+------------------+-------------+-------------+--------------+-------------------------------
-- database_size                 | appdb            | 21474836480 | 20 GB       |      8123911 | database bytes and xid age
-- largest_relations             | public.orders    | 10737418240 | 10 GB       |       382911 | largest tables/materialized...
-- replication_slot_retained_wal | logical_app_01   |   536870912 | 512 MB      |              | WAL retained by replication slot
-- SAMPLE_OUTPUT_END
