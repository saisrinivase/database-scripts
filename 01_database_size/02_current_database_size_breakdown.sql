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
