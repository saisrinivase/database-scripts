/*
PostgreSQL DBA Script: Tables Missing Primary Key
Purpose: Identify tables missing primary keys and generate starter DDL suggestions.
Area: Object Inventory and Health
Usage: Review result before adding PKs on production tables with existing duplicate/null values.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH candidates AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS table_name,
        c.oid AS relid,
        c.reltuples::bigint AS est_rows,
        pg_total_relation_size(c.oid) AS total_bytes
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    LEFT JOIN pg_constraint p
        ON p.conrelid = c.oid
       AND p.contype = 'p'
    WHERE c.relkind = 'r'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
      AND p.oid IS NULL
)
SELECT
    schema_name,
    table_name,
    est_rows,
    pg_size_pretty(total_bytes) AS total_size,
    format(
        'ALTER TABLE %I.%I ADD COLUMN id bigserial PRIMARY KEY;',
        schema_name,
        table_name
    ) AS starter_pk_sql
FROM candidates
ORDER BY total_bytes DESC, schema_name, table_name;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name |       table_name        | est_rows | total_size |                                    starter_pk_sql                                    
-- -------------+-------------------------+----------+------------+--------------------------------------------------------------------------------------
--  public      | pgbench_history         |  5331130 | 270 MB     | ALTER TABLE public.pgbench_history ADD COLUMN id bigserial PRIMARY KEY;
--  dba_metrics | connection_snapshots    |       -1 | 16 kB      | ALTER TABLE dba_metrics.connection_snapshots ADD COLUMN id bigserial PRIMARY KEY;
--  dba_metrics | database_size_snapshots |       -1 | 16 kB      | ALTER TABLE dba_metrics.database_size_snapshots ADD COLUMN id bigserial PRIMARY KEY;
--  dba_metrics | index_size_snapshots    |       -1 | 16 kB      | ALTER TABLE dba_metrics.index_size_snapshots ADD COLUMN id bigserial PRIMARY KEY;
--  dba_metrics | table_size_snapshots    |       -1 | 16 kB      | ALTER TABLE dba_metrics.table_size_snapshots ADD COLUMN id bigserial PRIMARY KEY;
--  dba_metrics | wal_snapshots           |       -1 | 16 kB      | ALTER TABLE dba_metrics.wal_snapshots ADD COLUMN id bigserial PRIMARY KEY;
-- (6 rows)
-- 
-- SAMPLE_OUTPUT_END
