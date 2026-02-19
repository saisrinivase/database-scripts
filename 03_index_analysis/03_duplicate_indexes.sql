/*
Purpose: Detect duplicate index definitions on the same table.
Area: Index Analysis
Usage: Validate access patterns before removing duplicates.
*/
WITH idx AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS table_name,
        i.indexrelid,
        ci.relname AS index_name,
        i.indrelid,
        i.indkey,
        i.indclass,
        i.indcollation,
        i.indoption,
        i.indpred,
        i.indexprs,
        i.indisunique,
        i.indisprimary,
        pg_relation_size(i.indexrelid) AS index_bytes
    FROM pg_index i
    JOIN pg_class c
        ON c.oid = i.indrelid
    JOIN pg_class ci
        ON ci.oid = i.indexrelid
    JOIN pg_namespace n
        ON n.oid = c.relnamespace
    WHERE n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
)
SELECT
    schema_name,
    table_name,
    array_agg(index_name ORDER BY index_name) AS duplicate_indexes,
    sum(index_bytes) AS total_duplicate_bytes,
    pg_size_pretty(sum(index_bytes)) AS total_duplicate_pretty
FROM idx
GROUP BY
    schema_name,
    table_name,
    indrelid,
    indkey,
    indclass,
    indcollation,
    indoption,
    indpred,
    indexprs,
    indisunique,
    indisprimary
HAVING count(*) > 1
ORDER BY total_duplicate_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name | table_name | duplicate_indexes | total_duplicate_bytes | total_duplicate_pretty 
-- -------------+------------+-------------------+-----------------------+------------------------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No issue/candidate rows were found at capture time.
-- - This typically indicates healthy state for this check; rerun during peak load for validation.
-- SAMPLE_OUTPUT_END
