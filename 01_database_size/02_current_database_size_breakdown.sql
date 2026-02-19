/*
Purpose: Break down current database storage into table, index, and TOAST components.
Area: Database Size
Usage: Run in the database you want to analyze.
*/
WITH base AS (
    SELECT
        c.oid,
        c.reltoastrelid
    FROM pg_class c
    JOIN pg_namespace n
        ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r', 'm')
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
)
SELECT
    pg_database_size(current_database()) AS database_total_bytes,
    pg_size_pretty(pg_database_size(current_database())) AS database_total_pretty,
    sum(pg_relation_size(b.oid)) AS table_heap_bytes,
    pg_size_pretty(sum(pg_relation_size(b.oid))) AS table_heap_pretty,
    sum(pg_indexes_size(b.oid)) AS indexes_bytes,
    pg_size_pretty(sum(pg_indexes_size(b.oid))) AS indexes_pretty,
    sum(CASE WHEN b.reltoastrelid = 0 THEN 0 ELSE pg_total_relation_size(b.reltoastrelid) END) AS toast_bytes,
    pg_size_pretty(sum(CASE WHEN b.reltoastrelid = 0 THEN 0 ELSE pg_total_relation_size(b.reltoastrelid) END)) AS toast_pretty
FROM base b;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  database_total_bytes | database_total_pretty | table_heap_bytes | table_heap_pretty | indexes_bytes | indexes_pretty | toast_bytes | toast_pretty 
-- ----------------------+-----------------------+------------------+-------------------+---------------+----------------+-------------+--------------
--           32236762815 | 30 GB                 |      27656060928 | 26 GB             |    4562763776 | 4351 MB        |      204800 | 200 kB
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
