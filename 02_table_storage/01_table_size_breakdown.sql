/*
PostgreSQL DBA Script: Table Size Breakdown
Purpose: Reconcile every table into main, auxiliary, index, TOAST, and true total storage with percentages.
Area: Table Storage
Usage: Run in the target database; add a schema/table predicate when a narrower review is needed.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: total_bytes uses pg_total_relation_size() and includes all listed components. TOAST bytes include the TOAST heap, index, and auxiliary forks.
*/
WITH sizes AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS table_name,
        pg_relation_size(c.oid, 'main') AS main_fork_bytes,
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
),
reconciled AS (
    SELECT
        *,
        greatest(total_bytes - main_fork_bytes - index_bytes - toast_bytes, 0) AS auxiliary_fork_bytes
    FROM sizes
)
SELECT
    schema_name,
    table_name,
    main_fork_bytes,
    pg_size_pretty(main_fork_bytes) AS main_fork_pretty,
    auxiliary_fork_bytes,
    pg_size_pretty(auxiliary_fork_bytes) AS auxiliary_fork_pretty,
    index_bytes,
    pg_size_pretty(index_bytes) AS index_pretty,
    round(100.0 * index_bytes / NULLIF(total_bytes, 0), 2) AS index_pct,
    toast_bytes,
    pg_size_pretty(toast_bytes) AS toast_pretty,
    round(100.0 * toast_bytes / NULLIF(total_bytes, 0), 2) AS toast_pct,
    total_bytes,
    pg_size_pretty(total_bytes) AS total_pretty,
    main_fork_bytes + auxiliary_fork_bytes + index_bytes + toast_bytes = total_bytes AS components_reconcile
FROM reconciled
ORDER BY total_bytes DESC;

-- SAMPLE_OUTPUT_BEGIN
-- schema_name | table_name | main_fork_pretty | auxiliary_fork_pretty | index_pretty | index_pct | toast_pretty | toast_pct | total_pretty | components_reconcile
-- ------------+------------+------------------+-----------------------+--------------+-----------+--------------+-----------+--------------+---------------------
-- public      | orders     | 700 MB           | 8 MB                  | 192 MB       | 19.20     | 100 MB       | 10.00     | 1000 MB      | t
-- SAMPLE_OUTPUT_END
