/*
Purpose: Show table-level PK/FK/index health for user schemas.
Area: Object Inventory and Health
Usage: Use as a broad relational integrity baseline before tuning and migrations.
*/
WITH user_tables AS (
    SELECT
        c.oid AS relid,
        n.nspname AS schema_name,
        c.relname AS table_name,
        c.reltuples::bigint AS est_rows,
        pg_total_relation_size(c.oid) AS total_bytes
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r', 'p')
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
),
pk AS (
    SELECT conrelid AS relid, count(*)::int AS pk_count
    FROM pg_constraint
    WHERE contype = 'p'
    GROUP BY conrelid
),
outbound_fk AS (
    SELECT conrelid AS relid, count(*)::int AS outbound_fk_count
    FROM pg_constraint
    WHERE contype = 'f'
    GROUP BY conrelid
),
inbound_fk AS (
    SELECT confrelid AS relid, count(*)::int AS inbound_fk_count
    FROM pg_constraint
    WHERE contype = 'f'
    GROUP BY confrelid
),
valid_idx AS (
    SELECT indrelid AS relid, count(*)::int AS valid_index_count
    FROM pg_index
    WHERE indisvalid
      AND indisready
    GROUP BY indrelid
)
SELECT
    t.schema_name,
    t.table_name,
    t.est_rows,
    pg_size_pretty(t.total_bytes) AS total_size,
    CASE WHEN coalesce(pk.pk_count, 0) > 0 THEN 'YES' ELSE 'NO' END AS has_primary_key,
    coalesce(outbound_fk.outbound_fk_count, 0) AS outbound_fk_count,
    coalesce(inbound_fk.inbound_fk_count, 0) AS inbound_fk_count,
    coalesce(valid_idx.valid_index_count, 0) AS valid_index_count,
    CASE
        WHEN coalesce(pk.pk_count, 0) = 0 THEN 'ADD_PRIMARY_KEY'
        WHEN coalesce(outbound_fk.outbound_fk_count, 0) > 0
             AND coalesce(valid_idx.valid_index_count, 0) = 0 THEN 'CHECK_FK_INDEXING'
        ELSE 'OK'
    END AS health_flag
FROM user_tables t
LEFT JOIN pk ON pk.relid = t.relid
LEFT JOIN outbound_fk ON outbound_fk.relid = t.relid
LEFT JOIN inbound_fk ON inbound_fk.relid = t.relid
LEFT JOIN valid_idx ON valid_idx.relid = t.relid
ORDER BY
    CASE WHEN coalesce(pk.pk_count, 0) = 0 THEN 0 ELSE 1 END,
    t.total_bytes DESC,
    t.schema_name,
    t.table_name;
