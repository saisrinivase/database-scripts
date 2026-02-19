/*
Purpose: Detect foreign keys lacking a matching index on referencing columns.
Area: Optimizing Data Modification
Usage: Missing FK indexes can hurt UPDATE/DELETE performance on parent tables.
*/
WITH fk AS (
    SELECT
        c.oid AS constraint_oid,
        c.conname,
        c.conrelid,
        c.confrelid,
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
idx AS (
    SELECT
        i.indrelid,
        i.indkey,
        i.indisvalid,
        i.indisready
    FROM pg_index i
)
SELECT
    fk.schema_name,
    fk.table_name,
    fk.conname AS foreign_key_name,
    fk.conkey AS fk_columns_attnums
FROM fk
WHERE NOT EXISTS (
    SELECT 1
    FROM idx
    WHERE idx.indrelid = fk.conrelid
      AND idx.indisvalid
      AND idx.indisready
      AND (idx.indkey::smallint[])[1:array_length(fk.conkey, 1)] = fk.conkey
)
ORDER BY fk.schema_name, fk.table_name, fk.conname;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |     table_name     |          foreign_key_name          | fk_columns_attnums 
-- ------------------+--------------------+------------------------------------+--------------------
--  migration_v1_lab | child_transactions | child_transactions_account_id_fkey | {2}
--  migration_v2_lab | child_events       | child_events_account_id_fkey       | {2}
-- (2 rows)
-- 
-- SAMPLE_OUTPUT_END
