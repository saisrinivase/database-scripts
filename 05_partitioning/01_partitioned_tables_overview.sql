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
