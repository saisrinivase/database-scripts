/*
Purpose: Show partitioned tables, partition key definition, and child count.
Area: Partitioning
Usage: Run in target database.
*/
SELECT
    pn.nspname AS parent_schema,
    pc.relname AS partitioned_table,
    pg_get_partkeydef(pc.oid) AS partition_key,
    count(i.inhrelid) AS partition_count
FROM pg_class pc
JOIN pg_namespace pn
    ON pn.oid = pc.relnamespace
LEFT JOIN pg_inherits i
    ON i.inhparent = pc.oid
WHERE pc.relkind = 'p'
GROUP BY pn.nspname, pc.relname, pc.oid
ORDER BY partition_count DESC, parent_schema, partitioned_table;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--   parent_schema   | partitioned_table  |   partition_key    | partition_count 
-- ------------------+--------------------+--------------------+-----------------
--  migration_v2_lab | partitioned_events | RANGE (event_date) |               2
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
