/*
Purpose: Detect TOAST/catalog linkage anomalies that can indicate deeper metadata inconsistencies.
Area: Consistency and Integrity Checks
Usage: Any non-empty result should be reviewed immediately.
*/
WITH toast_namespace AS (
    SELECT oid AS nspoid
    FROM pg_namespace
    WHERE nspname = 'pg_toast'
),
orphan_toast AS (
    SELECT
        'ORPHAN_TOAST_TABLE'::text AS anomaly_type,
        n.nspname AS schema_name,
        t.relname AS object_name,
        t.oid AS object_oid,
        'TOAST table has no parent relation referencing reltoastrelid.'::text AS details
    FROM pg_class t
    JOIN pg_namespace n
      ON n.oid = t.relnamespace
    WHERE t.relkind = 't'
      AND t.relnamespace = (SELECT nspoid FROM toast_namespace)
      AND NOT EXISTS (
            SELECT 1
            FROM pg_class p
            WHERE p.reltoastrelid = t.oid
      )
),
missing_toast AS (
    SELECT
        'MISSING_TOAST_RELATION'::text AS anomaly_type,
        n.nspname AS schema_name,
        c.relname AS object_name,
        c.oid AS object_oid,
        format('reltoastrelid=%s does not exist in pg_class', c.reltoastrelid) AS details
    FROM pg_class c
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r', 'm')
      AND c.reltoastrelid <> 0
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
      AND NOT EXISTS (
            SELECT 1
            FROM pg_class t
            WHERE t.oid = c.reltoastrelid
      )
)
SELECT *
FROM orphan_toast
UNION ALL
SELECT *
FROM missing_toast
ORDER BY anomaly_type, schema_name, object_name;


-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_new_areas_20260219_refresh
--
--  anomaly_type | schema_name | object_name | object_oid | details 
-- --------------+-------------+-------------+------------+---------
-- (0 rows)
-- 
-- SAMPLE_OUTPUT_END
