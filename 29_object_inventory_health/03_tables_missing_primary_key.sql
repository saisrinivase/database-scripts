/*
Purpose: Identify tables missing primary keys and generate starter DDL suggestions.
Area: Object Inventory and Health
Usage: Review result before adding PKs on production tables with existing duplicate/null values.
*/
WITH candidates AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS table_name,
        c.oid AS relid,
        c.reltuples::bigint AS est_rows,
        pg_total_relation_size(c.oid) AS total_bytes
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    LEFT JOIN pg_constraint p
        ON p.conrelid = c.oid
       AND p.contype = 'p'
    WHERE c.relkind = 'r'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
      AND p.oid IS NULL
)
SELECT
    schema_name,
    table_name,
    est_rows,
    pg_size_pretty(total_bytes) AS total_size,
    format(
        'ALTER TABLE %I.%I ADD COLUMN id bigserial PRIMARY KEY;',
        schema_name,
        table_name
    ) AS starter_pk_sql
FROM candidates
ORDER BY total_bytes DESC, schema_name, table_name;
