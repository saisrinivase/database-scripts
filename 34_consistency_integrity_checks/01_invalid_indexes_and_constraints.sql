/*
PostgreSQL DBA Script: Invalid Indexes And Constraints
Purpose: Detect invalid indexes and unvalidated constraints that indicate integrity or migration risk.
Area: Consistency and Integrity Checks
Usage: Investigate all rows; invalid metadata can break optimizer behavior and DDL safety.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH invalid_indexes AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS object_name,
        'INDEX'::text AS object_type,
        CASE
            WHEN i.indisvalid = false THEN 'indisvalid=false'
            WHEN i.indisready = false THEN 'indisready=false'
            WHEN i.indcheckxmin = true THEN 'indcheckxmin=true'
            ELSE 'other_index_integrity_flag'
        END AS issue,
        pg_get_indexdef(c.oid) AS details,
        pg_size_pretty(pg_relation_size(c.oid)) AS index_size,
        'HIGH'::text AS severity
    FROM pg_index i
    JOIN pg_class c
      ON c.oid = i.indexrelid
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    WHERE (i.indisvalid = false OR i.indisready = false OR i.indcheckxmin = true)
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
        NULL::text AS index_size,
        CASE WHEN con.contype = 'f' THEN 'HIGH' ELSE 'MEDIUM' END AS severity
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
    CASE severity WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 ELSE 3 END,
    schema_name,
    object_name;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh2
--
--  schema_name | object_name | object_type | issue | details | index_size | severity 
-- -------------+-------------+-------------+-------+---------+------------+----------
-- (0 rows)
-- 
-- SAMPLE_OUTPUT_END

