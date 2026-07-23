/*
PostgreSQL DBA Script: Top Largest Tables
Purpose: Rank the largest tables by true total footprint and show how much is index and TOAST storage.
Area: Table Storage
Usage: Change LIMIT when more than the top 50 tables are needed.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: total_bytes uses pg_total_relation_size() and includes the table, auxiliary forks, indexes, and TOAST.
*/
WITH sizes AS (
    SELECT
        c.oid,
        n.nspname AS schema_name,
        c.relname AS table_name,
        pg_indexes_size(c.oid) AS index_bytes,
        CASE
            WHEN c.reltoastrelid = 0 THEN 0
            ELSE pg_total_relation_size(c.reltoastrelid)
        END AS toast_bytes,
        pg_total_relation_size(c.oid) AS total_bytes
    FROM pg_class c
    JOIN pg_namespace n
        ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r', 'm')
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
)
SELECT
    z.schema_name,
    z.table_name,
    z.total_bytes,
    pg_size_pretty(z.total_bytes) AS total_pretty,
    z.index_bytes,
    pg_size_pretty(z.index_bytes) AS index_pretty,
    round(100.0 * z.index_bytes / NULLIF(z.total_bytes, 0), 2) AS index_pct,
    z.toast_bytes,
    pg_size_pretty(z.toast_bytes) AS toast_pretty,
    round(100.0 * z.toast_bytes / NULLIF(z.total_bytes, 0), 2) AS toast_pct,
    s.n_live_tup AS estimated_live_rows,
    s.n_dead_tup AS estimated_dead_rows
FROM sizes z
LEFT JOIN pg_stat_user_tables s
    ON s.relid = z.oid
ORDER BY z.total_bytes DESC
LIMIT 50;

-- SAMPLE_OUTPUT_BEGIN
-- schema_name | table_name | total_pretty | index_pretty | index_pct | toast_pretty | toast_pct | estimated_live_rows | estimated_dead_rows
-- ------------+------------+--------------+--------------+-----------+--------------+-----------+---------------------+--------------------
-- public      | orders     | 1000 MB      | 192 MB       | 19.20     | 100 MB       | 10.00     | 5000000             | 250000
-- SAMPLE_OUTPUT_END
