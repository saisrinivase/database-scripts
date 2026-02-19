/*
Purpose: Identify partitions that have zero indexes defined.
Area: Partitioning
Usage: Review query plans before adding indexes to every partition.
*/
WITH child_index_count AS (
    SELECT
        indrelid,
        count(*) AS index_count
    FROM pg_index
    GROUP BY indrelid
)
SELECT
    pns.nspname AS parent_schema,
    p.relname AS parent_table,
    cns.nspname AS partition_schema,
    c.relname AS partition_name,
    coalesce(ci.index_count, 0) AS index_count
FROM pg_inherits i
JOIN pg_class p
    ON p.oid = i.inhparent
JOIN pg_namespace pns
    ON pns.oid = p.relnamespace
JOIN pg_class c
    ON c.oid = i.inhrelid
JOIN pg_namespace cns
    ON cns.oid = c.relnamespace
LEFT JOIN child_index_count ci
    ON ci.indrelid = c.oid
WHERE coalesce(ci.index_count, 0) = 0
ORDER BY parent_schema, parent_table, partition_schema, partition_name;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--   parent_schema   |      parent_table       | partition_schema |        partition_name        | index_count 
-- ------------------+-------------------------+------------------+------------------------------+-------------
--  migration_v2_lab | partitioned_events_pkey | migration_v2_lab | partitioned_events_2025_pkey |           0
--  migration_v2_lab | partitioned_events_pkey | migration_v2_lab | partitioned_events_2026_pkey |           0
-- (2 rows)
-- 
-- SAMPLE_OUTPUT_END
