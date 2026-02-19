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


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 parent_schema | parent_table | partition_schema | partition_name | partition_bytes | partition_pretty 
---------------+--------------+------------------+----------------+-----------------+------------------
(0 rows)


SAMPLE_OUTPUT_END */
