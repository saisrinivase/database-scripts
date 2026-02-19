/*
Purpose: Find foreign keys where referencing columns are not backed by a suitable index prefix.
Area: Object Inventory and Health
Usage: Create suggested indexes after validating workload and existing composite index strategy.
*/
WITH fk AS (
    SELECT
        c.oid AS constraint_oid,
        c.conname,
        c.conrelid,
        c.conkey,
        n.nspname AS schema_name,
        t.relname AS table_name
    FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE c.contype = 'f'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
),
fk_cols AS (
    SELECT
        f.constraint_oid,
        string_agg(quote_ident(a.attname), ', ' ORDER BY k.ord) AS fk_columns,
        min(a.attname) AS first_fk_col
    FROM fk f
    JOIN LATERAL unnest(f.conkey) WITH ORDINALITY AS k(attnum, ord)
      ON true
    JOIN pg_attribute a
      ON a.attrelid = f.conrelid
     AND a.attnum = k.attnum
    GROUP BY f.constraint_oid
)
SELECT
    f.schema_name,
    f.table_name,
    f.conname AS foreign_key_name,
    c.fk_columns,
    format(
        'CREATE INDEX CONCURRENTLY %I ON %I.%I (%s);',
        left('idx_' || f.table_name || '_' || replace(f.conname, ' ', '_'), 60),
        f.schema_name,
        f.table_name,
        c.fk_columns
    ) AS suggested_index_sql
FROM fk f
JOIN fk_cols c
  ON c.constraint_oid = f.constraint_oid
WHERE NOT EXISTS (
    SELECT 1
    FROM pg_index i
    WHERE i.indrelid = f.conrelid
      AND i.indisvalid
      AND i.indisready
      AND (
          (i.indkey::smallint[])[
              array_lower(i.indkey::smallint[], 1):
              array_lower(i.indkey::smallint[], 1) + array_length(f.conkey, 1) - 1
          ]
      ) = f.conkey
)
ORDER BY f.schema_name, f.table_name, f.conname;


/* SAMPLE_OUTPUT_BEGIN
Sample output (captured from local validation run; values may vary by environment).

 schema_name | table_name | foreign_key_name | fk_columns | suggested_index_sql 
-------------+------------+------------------+------------+---------------------
(0 rows)


SAMPLE_OUTPUT_END */
