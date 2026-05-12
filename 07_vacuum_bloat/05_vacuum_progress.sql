/*
PostgreSQL DBA Script: Vacuum Progress
Purpose: Monitor currently running VACUUM operations.
Area: Vacuum and Bloat
Usage: Requires pg_stat_progress_vacuum view. Safe for pgAdmin and psql.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic. PostgreSQL version-specific vacuum progress columns are handled dynamically.
*/
CREATE TEMP TABLE IF NOT EXISTS vacuum_progress_result (
    pid integer,
    schema_name name,
    table_name name,
    phase text,
    heap_blks_total bigint,
    heap_blks_scanned bigint,
    heap_blks_vacuumed bigint,
    index_vacuum_count bigint,
    max_dead_tuple_bytes bigint,
    dead_tuple_bytes bigint,
    num_dead_item_ids bigint,
    max_dead_tuples bigint,
    num_dead_tuples bigint
);

TRUNCATE vacuum_progress_result;

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_attribute
        WHERE attrelid = 'pg_catalog.pg_stat_progress_vacuum'::regclass
          AND attname = 'dead_tuple_bytes'
    ) THEN
        EXECUTE $sql$
            INSERT INTO vacuum_progress_result
            SELECT
                p.pid,
                n.nspname,
                c.relname,
                p.phase,
                p.heap_blks_total,
                p.heap_blks_scanned,
                p.heap_blks_vacuumed,
                p.index_vacuum_count,
                p.max_dead_tuple_bytes,
                p.dead_tuple_bytes,
                p.num_dead_item_ids,
                NULL::bigint,
                NULL::bigint
            FROM pg_stat_progress_vacuum p
            JOIN pg_class c ON c.oid = p.relid
            JOIN pg_namespace n ON n.oid = c.relnamespace
        $sql$;
    ELSE
        EXECUTE $sql$
            INSERT INTO vacuum_progress_result
            SELECT
                p.pid,
                n.nspname,
                c.relname,
                p.phase,
                p.heap_blks_total,
                p.heap_blks_scanned,
                p.heap_blks_vacuumed,
                p.index_vacuum_count,
                NULL::bigint,
                NULL::bigint,
                NULL::bigint,
                p.max_dead_tuples,
                p.num_dead_tuples
            FROM pg_stat_progress_vacuum p
            JOIN pg_class c ON c.oid = p.relid
            JOIN pg_namespace n ON n.oid = c.relnamespace
        $sql$;
    END IF;
END $$;

SELECT *
FROM vacuum_progress_result
ORDER BY pid;

-- SAMPLE_OUTPUT_BEGIN
-- pid | schema_name | table_name | phase | heap_blks_total | heap_blks_scanned | heap_blks_vacuumed
-- ----+-------------+------------+-------+-----------------+-------------------+--------------------
-- (0 rows)
-- SAMPLE_OUTPUT_END
