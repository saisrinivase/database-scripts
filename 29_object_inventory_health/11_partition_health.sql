/*
Purpose: Assess partitioned table coverage, size distribution, and index gaps on leaf partitions.
Area: Object Inventory and Health
Usage: Run after partition changes or when large scans appear on partitioned workloads.
*/
WITH parents AS (
    SELECT
        c.oid AS parent_oid,
        n.nspname AS schema_name,
        c.relname AS partitioned_table,
        pg_get_partkeydef(c.oid) AS partition_key
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind = 'p'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
),
leaf_nodes AS (
    SELECT
        p.parent_oid,
        pt.relid AS leaf_oid
    FROM parents p
    JOIN LATERAL pg_partition_tree(p.parent_oid) pt ON true
    WHERE pt.isleaf
),
leaf_index_health AS (
    SELECT
        l.parent_oid,
        l.leaf_oid,
        count(*) FILTER (WHERE i.indisvalid AND i.indisready) AS valid_index_count
    FROM leaf_nodes l
    LEFT JOIN pg_index i ON i.indrelid = l.leaf_oid
    GROUP BY l.parent_oid, l.leaf_oid
),
leaf_sizes AS (
    SELECT
        l.parent_oid,
        sum(pg_total_relation_size(l.leaf_oid))::bigint AS total_leaf_bytes
    FROM leaf_nodes l
    GROUP BY l.parent_oid
)
SELECT
    p.schema_name,
    p.partitioned_table,
    p.partition_key,
    count(l.leaf_oid)::bigint AS leaf_partition_count,
    count(l.leaf_oid) FILTER (WHERE h.valid_index_count = 0)::bigint AS leaf_partitions_without_valid_index,
    pg_size_pretty(coalesce(s.total_leaf_bytes, 0)) AS total_leaf_size,
    CASE
        WHEN count(l.leaf_oid) = 0 THEN 'NO_LEAF_PARTITIONS'
        WHEN count(l.leaf_oid) FILTER (WHERE h.valid_index_count = 0) > 0 THEN 'CHECK_LEAF_INDEX_STRATEGY'
        ELSE 'OK'
    END AS partition_health_flag
FROM parents p
LEFT JOIN leaf_nodes l ON l.parent_oid = p.parent_oid
LEFT JOIN leaf_index_health h
  ON h.parent_oid = l.parent_oid
 AND h.leaf_oid = l.leaf_oid
LEFT JOIN leaf_sizes s ON s.parent_oid = p.parent_oid
GROUP BY p.schema_name, p.partitioned_table, p.partition_key, s.total_leaf_bytes
ORDER BY p.schema_name, p.partitioned_table;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

   schema_name    | partitioned_table  |   partition_key    | leaf_partition_count | leaf_partitions_without_valid_index | total_leaf_size | partition_health_flag 
------------------+--------------------+--------------------+----------------------+-------------------------------------+-----------------+-----------------------
 migration_v2_lab | partitioned_events | RANGE (event_date) |                    2 |                                   0 | 10 MB           | OK
(1 row)


SAMPLE_OUTPUT_END */
