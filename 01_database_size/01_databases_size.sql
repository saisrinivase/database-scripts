/*
PostgreSQL DBA Script: Databases Size
Purpose: Rank all databases by total size and expose heap, index, and TOAST usage for the connected database.
Area: Database Size
Usage: Connect to each database when its component breakdown is needed; PostgreSQL relation catalogs are database-local. On very large or file-dense clusters, run during a low-load window with a statement timeout.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: pg_database_size() already includes table, index, TOAST, and catalog storage. It is evaluated once per database here, but still traverses database storage. Component columns are exact only for the connected database and remain NULL for other databases.
*/
WITH relation_sizes AS (
    SELECT
        pg_total_relation_size(c.oid) AS relation_total_bytes,
        pg_indexes_size(c.oid) AS index_bytes,
        CASE
            WHEN c.reltoastrelid = 0 THEN 0
            ELSE pg_total_relation_size(c.reltoastrelid)
        END AS toast_bytes
    FROM pg_class c
    JOIN pg_namespace n
        ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r', 'm')
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
),
connected_database AS (
    SELECT
        current_database() AS database_name,
        coalesce(sum(relation_total_bytes - index_bytes - toast_bytes), 0)::bigint AS table_heap_bytes,
        coalesce(sum(index_bytes), 0)::bigint AS index_bytes,
        coalesce(sum(toast_bytes), 0)::bigint AS toast_bytes,
        coalesce(sum(relation_total_bytes), 0)::bigint AS user_relations_total_bytes
    FROM relation_sizes
), database_sizes AS (
    SELECT
        d.datname,
        pg_database_size(d.datname) AS size_bytes
    FROM pg_database d
)
SELECT
    d.datname AS database_name,
    d.size_bytes,
    pg_size_pretty(d.size_bytes) AS size_pretty,
    d.datname = current_database() AS is_connected_database,
    CASE WHEN d.datname = current_database() THEN c.table_heap_bytes END AS table_heap_bytes,
    CASE WHEN d.datname = current_database() THEN pg_size_pretty(c.table_heap_bytes) END AS table_heap_pretty,
    CASE WHEN d.datname = current_database() THEN c.index_bytes END AS index_bytes,
    CASE WHEN d.datname = current_database() THEN pg_size_pretty(c.index_bytes) END AS index_pretty,
    CASE WHEN d.datname = current_database() THEN c.toast_bytes END AS toast_bytes,
    CASE WHEN d.datname = current_database() THEN pg_size_pretty(c.toast_bytes) END AS toast_pretty,
    CASE
        WHEN d.datname = current_database()
        THEN round(100.0 * c.toast_bytes / NULLIF(d.size_bytes, 0), 2)
    END AS toast_pct_of_database,
    CASE
        WHEN d.datname = current_database()
        THEN c.user_relations_total_bytes
    END AS user_relations_total_bytes,
    CASE
        WHEN d.datname = current_database()
        THEN pg_size_pretty(c.user_relations_total_bytes)
    END AS user_relations_total_pretty,
    CASE
        WHEN d.datname = current_database()
        THEN greatest(d.size_bytes - c.user_relations_total_bytes, 0)
    END AS catalogs_and_other_bytes,
    CASE
        WHEN d.datname = current_database()
        THEN pg_size_pretty(greatest(d.size_bytes - c.user_relations_total_bytes, 0))
    END AS catalogs_and_other_pretty,
    CASE
        WHEN d.datname = current_database() THEN 'BREAKDOWN_AVAILABLE'
        ELSE 'CONNECT_TO_DATABASE_FOR_BREAKDOWN'
    END AS breakdown_status
FROM database_sizes d
CROSS JOIN connected_database c
ORDER BY size_bytes DESC;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  database_name | size_bytes | size_pretty | is_connected_database | table_heap_bytes | table_heap_pretty | index_bytes | index_pretty | toast_bytes | toast_pretty | toast_pct_of_database | user_relations_total_bytes | user_relations_total_pretty | catalogs_and_other_bytes | catalogs_and_other_pretty | breakdown_status
-- ---------------+------------+-------------+-----------------------+------------------+-------------------+-------------+--------------+-------------+--------------+-----------------------+----------------------------+-----------------------------+--------------------------+---------------------------+-----------------------------------
--  appdb          | 1073741824 | 1024 MB     | t                     |        734003200 | 700 MB            |   209715200 | 200 MB       |    52428800 | 50 MB        |                  4.88 |                  996147200 | 950 MB                      |                 77594624 | 74 MB                     | BREAKDOWN_AVAILABLE
--  postgres       |   41943040 | 40 MB       | f                     |                  |                   |             |              |             |              |                       |                            |                             |                          |                           | CONNECT_TO_DATABASE_FOR_BREAKDOWN
-- (2 rows shown)
-- 
-- SAMPLE_OUTPUT_END
