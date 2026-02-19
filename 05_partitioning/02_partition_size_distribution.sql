/*
Purpose: Show partition sizes under each parent table.
Area: Partitioning
Usage: Helps rebalance uneven partition growth.
*/
SELECT
    pns.nspname AS parent_schema,
    p.relname AS parent_table,
    cns.nspname AS partition_schema,
    c.relname AS partition_name,
    pg_total_relation_size(c.oid) AS partition_bytes,
    pg_size_pretty(pg_total_relation_size(c.oid)) AS partition_pretty
FROM pg_inherits i
JOIN pg_class p
    ON p.oid = i.inhparent
JOIN pg_namespace pns
    ON pns.oid = p.relnamespace
JOIN pg_class c
    ON c.oid = i.inhrelid
JOIN pg_namespace cns
    ON cns.oid = c.relnamespace
ORDER BY partition_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--   parent_schema   |      parent_table       | partition_schema |        partition_name        | partition_bytes | partition_pretty 
-- ------------------+-------------------------+------------------+------------------------------+-----------------+------------------
--  migration_v2_lab | partitioned_events      | migration_v2_lab | partitioned_events_2025      |         5693440 | 5560 kB
--  migration_v2_lab | partitioned_events      | migration_v2_lab | partitioned_events_2026      |         5226496 | 5104 kB
--  migration_v2_lab | partitioned_events_pkey | migration_v2_lab | partitioned_events_2025_pkey |         1654784 | 1616 kB
--  migration_v2_lab | partitioned_events_pkey | migration_v2_lab | partitioned_events_2026_pkey |         1523712 | 1488 kB
-- (4 rows)
-- 
-- SAMPLE_OUTPUT_END
