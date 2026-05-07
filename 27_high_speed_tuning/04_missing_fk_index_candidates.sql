/*
PostgreSQL DBA Script: Missing FK Index Candidates
Purpose: Find foreign keys without supporting indexes on referencing columns.
Area: High Speed Tuning
Usage: Missing FK indexes often cause DELETE/UPDATE slowdown on parent tables.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
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
    JOIN pg_class t
        ON t.oid = c.conrelid
    JOIN pg_namespace n
        ON n.oid = t.relnamespace
    WHERE c.contype = 'f'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
),
fk_cols AS (
    SELECT
        f.constraint_oid,
        string_agg(quote_ident(a.attname), ', ' ORDER BY k.ord) AS fk_columns
    FROM fk f
    JOIN LATERAL unnest(f.conkey) WITH ORDINALITY AS k(attnum, ord)
        ON true
    JOIN pg_attribute a
        ON a.attrelid = f.conrelid
       AND a.attnum = k.attnum
    GROUP BY f.constraint_oid
),
idx AS (
    SELECT
        i.indrelid,
        i.indkey::smallint[] AS indkey,
        i.indisvalid,
        i.indisready
    FROM pg_index i
)
SELECT
    f.schema_name,
    f.table_name,
    f.conname AS foreign_key_name,
    c.fk_columns,
    format(
        'CREATE INDEX CONCURRENTLY %I ON %I.%I (%s);',
        'idx_' || f.table_name || '_' || replace(f.conname, ' ', '_'),
        f.schema_name,
        f.table_name,
        c.fk_columns
    ) AS suggested_index_sql
FROM fk f
JOIN fk_cols c
    ON c.constraint_oid = f.constraint_oid
WHERE NOT EXISTS (
    SELECT 1
    FROM idx
    WHERE idx.indrelid = f.conrelid
      AND idx.indisvalid
      AND idx.indisready
      AND idx.indkey[1:array_length(f.conkey, 1)] = f.conkey
)
ORDER BY f.schema_name, f.table_name, f.conname;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |     table_name     |          foreign_key_name          | fk_columns |                                                           suggested_index_sql                                                            
-- ------------------+--------------------+------------------------------------+------------+------------------------------------------------------------------------------------------------------------------------------------------
--  migration_v1_lab | child_transactions | child_transactions_account_id_fkey | account_id | CREATE INDEX CONCURRENTLY idx_child_transactions_child_transactions_account_id_fkey ON migration_v1_lab.child_transactions (account_id);
--  migration_v2_lab | child_events       | child_events_account_id_fkey       | account_id | CREATE INDEX CONCURRENTLY idx_child_events_child_events_account_id_fkey ON migration_v2_lab.child_events (account_id);
-- (2 rows)
-- 
-- SAMPLE_OUTPUT_END
