/*
Purpose: Identify invalid indexes and NOT VALID constraints that can break upgrade confidence.
Area: Upgrade and Patch Readiness
Usage: Resolve all CRITICAL rows before major version upgrades.
*/
WITH invalid_indexes AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS object_name,
        'INDEX'::text AS object_type,
        CASE
            WHEN i.indisvalid = false THEN 'indisvalid=false'
            WHEN i.indisready = false THEN 'indisready=false'
            ELSE 'other'
        END AS issue,
        pg_get_indexdef(c.oid) AS details,
        'CRITICAL'::text AS severity
    FROM pg_index i
    JOIN pg_class c
      ON c.oid = i.indexrelid
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    WHERE (i.indisvalid = false OR i.indisready = false)
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
),
not_valid_constraints AS (
    SELECT
        n.nspname AS schema_name,
        con.conname AS object_name,
        'CONSTRAINT'::text AS object_type,
        'convalidated=false'::text AS issue,
        pg_get_constraintdef(con.oid) AS details,
        CASE
            WHEN con.contype IN ('f', 'c') THEN 'HIGH'
            ELSE 'MEDIUM'
        END AS severity
    FROM pg_constraint con
    JOIN pg_class tbl
      ON tbl.oid = con.conrelid
    JOIN pg_namespace n
      ON n.oid = tbl.relnamespace
    WHERE con.convalidated = false
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
),
combined AS (
    SELECT *
    FROM invalid_indexes
    UNION ALL
    SELECT *
    FROM not_valid_constraints
)
SELECT *
FROM combined
ORDER BY
    CASE severity
        WHEN 'CRITICAL' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        ELSE 4
    END,
    schema_name,
    object_name;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh2
--
--  schema_name | object_name | object_type | issue | details | severity 
-- -------------+-------------+-------------+-------+---------+----------
-- (0 rows)
-- 
-- SAMPLE_OUTPUT_END
