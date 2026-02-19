/*
Purpose: List advanced index access methods used for complex filtering/search patterns.
Area: Complex Filtering and Search
Usage: Validate index-method alignment with workload.
*/
SELECT
    n.nspname AS schema_name,
    t.relname AS table_name,
    i.relname AS index_name,
    am.amname AS access_method,
    pg_size_pretty(pg_relation_size(i.oid)) AS index_size
FROM pg_index x
JOIN pg_class i
    ON i.oid = x.indexrelid
JOIN pg_class t
    ON t.oid = x.indrelid
JOIN pg_namespace n
    ON n.oid = t.relnamespace
JOIN pg_am am
    ON am.oid = i.relam
WHERE n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
  AND am.amname IN ('gin', 'gist', 'brin')
ORDER BY access_method, pg_relation_size(i.oid) DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name | table_name | index_name | access_method | index_size 
-- -------------+------------+------------+---------------+------------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No rows matched in this environment at capture time.
-- - This can be expected when the related object/feature is not present or not in use.
-- SAMPLE_OUTPUT_END
