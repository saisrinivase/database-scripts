/*
PostgreSQL DBA Script: Current Database Size Breakdown
Purpose: Reconcile the connected database into user-table main forks, auxiliary forks, indexes, TOAST, and other database storage.
Area: Database Size
Usage: Run in each database that needs a component-level storage analysis.
Sample Output: See SAMPLE_OUTPUT_BEGIN at the bottom.
Notes: pg_database_size() is the authoritative database total and already includes TOAST. User-relation components exclude PostgreSQL catalogs and non-table objects.
*/
WITH relation_sizes AS (
    SELECT
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
component_totals AS (
    SELECT
        coalesce(sum(main_fork_bytes), 0)::bigint AS main_fork_bytes,
        coalesce(sum(greatest(total_bytes - main_fork_bytes - index_bytes - toast_bytes, 0)), 0)::bigint AS auxiliary_fork_bytes,
        coalesce(sum(index_bytes), 0)::bigint AS index_bytes,
        coalesce(sum(toast_bytes), 0)::bigint AS toast_bytes,
        coalesce(sum(total_bytes), 0)::bigint AS user_relations_total_bytes
    FROM relation_sizes
),
database_total AS (
    SELECT pg_database_size(current_database()) AS database_total_bytes
)
SELECT
    current_database() AS database_name,
    d.database_total_bytes,
    pg_size_pretty(d.database_total_bytes) AS database_total_pretty,
    c.main_fork_bytes AS user_table_main_fork_bytes,
    pg_size_pretty(c.main_fork_bytes) AS user_table_main_fork_pretty,
    c.auxiliary_fork_bytes AS user_table_auxiliary_fork_bytes,
    pg_size_pretty(c.auxiliary_fork_bytes) AS user_table_auxiliary_fork_pretty,
    c.index_bytes AS user_index_bytes,
    pg_size_pretty(c.index_bytes) AS user_index_pretty,
    c.toast_bytes AS user_toast_bytes,
    pg_size_pretty(c.toast_bytes) AS user_toast_pretty,
    round(100.0 * c.toast_bytes / NULLIF(d.database_total_bytes, 0), 2) AS toast_pct_of_database,
    c.user_relations_total_bytes,
    pg_size_pretty(c.user_relations_total_bytes) AS user_relations_total_pretty,
    greatest(d.database_total_bytes - c.user_relations_total_bytes, 0) AS catalogs_and_other_bytes,
    pg_size_pretty(greatest(d.database_total_bytes - c.user_relations_total_bytes, 0)) AS catalogs_and_other_pretty,
    c.main_fork_bytes
        + c.auxiliary_fork_bytes
        + c.index_bytes
        + c.toast_bytes = c.user_relations_total_bytes AS user_components_reconcile
FROM component_totals c
CROSS JOIN database_total d;

-- SAMPLE_OUTPUT_BEGIN
-- database_name | database_total_pretty | user_table_main_fork_pretty | user_table_auxiliary_fork_pretty | user_index_pretty | user_toast_pretty | toast_pct_of_database | user_relations_total_pretty | catalogs_and_other_pretty | user_components_reconcile
-- --------------+-----------------------+-----------------------------+----------------------------------+-------------------+-------------------+-----------------------+-----------------------------+---------------------------+--------------------------
-- appdb         | 1024 MB               | 700 MB                      | 8 MB                             | 192 MB            | 50 MB             | 4.88                  | 950 MB                      | 74 MB                     | t
-- SAMPLE_OUTPUT_END
