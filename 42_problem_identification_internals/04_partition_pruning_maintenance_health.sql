/*
PostgreSQL DBA Script: Partition Pruning Maintenance Health
Purpose: Detect pruning configuration, unbalanced leaves, default-partition accumulation, invalid indexes, and missing partition-maintenance capability.
Area: Problem Identification and Internals
Usage: Run in the target database, then validate flagged query predicates with EXPLAIN (ANALYZE, BUFFERS).
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: Read-only. Runtime pruning is plan-specific; inspect Subplans Removed and executed child nodes for the exact query.
*/
WITH parents AS (
    SELECT
        c.oid AS parent_oid,
        n.nspname AS schema_name,
        c.relname AS parent_table,
        pg_get_partkeydef(c.oid) AS partition_key
    FROM pg_partitioned_table p
    JOIN pg_class c ON c.oid = p.partrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
),
leaf_sizes AS (
    SELECT
        p.parent_oid,
        t.relid AS leaf_oid,
        pg_total_relation_size(t.relid) AS leaf_bytes
    FROM parents p
    CROSS JOIN LATERAL pg_partition_tree(p.parent_oid) t
    WHERE t.isleaf
),
leaf_summary AS (
    SELECT
        parent_oid,
        count(*) AS leaf_count,
        sum(leaf_bytes)::bigint AS total_leaf_bytes,
        min(leaf_bytes) AS smallest_leaf_bytes,
        max(leaf_bytes) AS largest_leaf_bytes
    FROM leaf_sizes
    GROUP BY parent_oid
),
defaults AS (
    SELECT
        i.inhparent AS parent_oid,
        count(*) FILTER (WHERE pg_get_expr(c.relpartbound, c.oid) = 'DEFAULT') AS default_partition_count,
        coalesce(sum(pg_total_relation_size(c.oid)) FILTER (WHERE pg_get_expr(c.relpartbound, c.oid) = 'DEFAULT'), 0)::bigint AS default_partition_bytes
    FROM pg_inherits i
    JOIN pg_class c ON c.oid = i.inhrelid
    GROUP BY i.inhparent
)
SELECT
    p.schema_name,
    p.parent_table,
    p.partition_key,
    coalesce(s.leaf_count, 0) AS leaf_count,
    pg_size_pretty(coalesce(s.total_leaf_bytes, 0)) AS total_leaf_size,
    pg_size_pretty(coalesce(s.smallest_leaf_bytes, 0)) AS smallest_leaf_size,
    pg_size_pretty(coalesce(s.largest_leaf_bytes, 0)) AS largest_leaf_size,
    coalesce(d.default_partition_count, 0) AS default_partition_count,
    pg_size_pretty(coalesce(d.default_partition_bytes, 0)) AS default_partition_size,
    CASE
        WHEN current_setting('enable_partition_pruning') <> 'on' THEN 'HIGH: PARTITION_PRUNING_DISABLED'
        WHEN coalesce(d.default_partition_bytes, 0) >= 1024::bigint * 1024 * 1024 * 1024 THEN 'HIGH: LARGE_DEFAULT_PARTITION'
        WHEN coalesce(s.leaf_count, 0) = 0 THEN 'HIGH: NO_LEAF_PARTITIONS'
        WHEN s.smallest_leaf_bytes > 0 AND s.largest_leaf_bytes >= s.smallest_leaf_bytes * 20 THEN 'REVIEW: STRONGLY_UNBALANCED_LEAVES'
        ELSE 'REVIEW_QUERY_PLAN'
    END AS diagnosis,
    'Use EXPLAIN (ANALYZE, BUFFERS) and verify Subplans Removed or that only expected leaf scans execute.' AS next_action
FROM parents p
LEFT JOIN leaf_summary s ON s.parent_oid = p.parent_oid
LEFT JOIN defaults d ON d.parent_oid = p.parent_oid
ORDER BY coalesce(s.total_leaf_bytes, 0) DESC, p.schema_name, p.parent_table;

SELECT
    pn.nspname AS parent_schema,
    pc.relname AS parent_table,
    cn.nspname AS child_schema,
    cc.relname AS child_table,
    ic.relname AS index_name,
    i.indisvalid,
    i.indisready,
    i.indislive,
    CASE
        WHEN NOT i.indisvalid THEN 'INVALID_PARTITION_INDEX'
        WHEN NOT i.indisready THEN 'INDEX_NOT_READY'
        WHEN NOT i.indislive THEN 'INDEX_NOT_LIVE'
        ELSE 'READY'
    END AS health_status
FROM pg_inherits inh
JOIN pg_class pc ON pc.oid = inh.inhparent AND pc.relkind = 'p'
JOIN pg_namespace pn ON pn.oid = pc.relnamespace
JOIN pg_class cc ON cc.oid = inh.inhrelid
JOIN pg_namespace cn ON cn.oid = cc.relnamespace
LEFT JOIN pg_index i ON i.indrelid = cc.oid
LEFT JOIN pg_class ic ON ic.oid = i.indexrelid
WHERE i.indexrelid IS NULL OR NOT i.indisvalid OR NOT i.indisready OR NOT i.indislive
ORDER BY pn.nspname, pc.relname, cn.nspname, cc.relname, ic.relname;

SELECT
    current_setting('enable_partition_pruning') AS enable_partition_pruning,
    EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_partman') AS pg_partman_installed,
    to_regclass('partman.part_config') IS NOT NULL AS pg_partman_config_visible,
    CASE
        WHEN current_setting('enable_partition_pruning') <> 'on' THEN 'Enable pruning after confirming why it was disabled.'
        WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_partman') THEN 'Review pg_partman configuration and maintenance job health.'
        ELSE 'Use a reviewed native or external partition creation and retention schedule.'
    END AS next_action;

-- SAMPLE_OUTPUT_BEGIN
-- schema_name | parent_table | partition_key | leaf_count | total_leaf_size | default_partition_size | diagnosis | next_action
-- enable_partition_pruning | pg_partman_installed | pg_partman_config_visible | next_action
-- SAMPLE_OUTPUT_END
