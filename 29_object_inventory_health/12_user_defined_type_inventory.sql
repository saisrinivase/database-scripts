/*
PostgreSQL DBA Script: User Defined Type Inventory
Purpose: Inventory custom types and show where they are used in table columns.
Area: Object Inventory and Health
Usage: Useful for migration audits and schema refactoring impact analysis.
Sample Output: See SAMPLE_OUTPUT_BEGIN block at the bottom for a representative result shape.
Notes: Read-only diagnostic unless the script explicitly creates objects, changes settings, or seeds/fixes lab data.
*/
WITH user_types AS (
    SELECT
        t.oid AS type_oid,
        n.nspname AS schema_name,
        t.typname AS type_name,
        CASE t.typtype
            WHEN 'd' THEN 'DOMAIN'
            WHEN 'e' THEN 'ENUM'
            WHEN 'c' THEN 'COMPOSITE'
            WHEN 'r' THEN 'RANGE'
            WHEN 'm' THEN 'MULTIRANGE'
            ELSE t.typtype::text
        END AS type_kind,
        t.typcategory
    FROM pg_type t
    JOIN pg_namespace n ON n.oid = t.typnamespace
    LEFT JOIN pg_class rc ON rc.oid = t.typrelid
    WHERE n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
      AND t.typtype IN ('c', 'd', 'e', 'm', 'r')
      AND (t.typtype <> 'c' OR rc.relkind = 'c')
),
col_usage AS (
    SELECT
        a.atttypid AS type_oid,
        count(*)::bigint AS used_in_column_count
    FROM pg_attribute a
    JOIN pg_class c ON c.oid = a.attrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE a.attnum > 0
      AND NOT a.attisdropped
      AND c.relkind IN ('r', 'p', 'v', 'm')
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
    GROUP BY a.atttypid
),
enum_labels AS (
    SELECT
        e.enumtypid AS type_oid,
        string_agg(e.enumlabel, ', ' ORDER BY e.enumsortorder) AS labels
    FROM pg_enum e
    GROUP BY e.enumtypid
)
SELECT
    t.schema_name,
    t.type_name,
    t.type_kind,
    t.typcategory,
    coalesce(c.used_in_column_count, 0) AS used_in_column_count,
    coalesce(e.labels, '') AS enum_labels
FROM user_types t
LEFT JOIN col_usage c ON c.type_oid = t.type_oid
LEFT JOIN enum_labels e ON e.type_oid = t.type_oid
ORDER BY t.schema_name, t.type_kind, t.type_name;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--    schema_name    |     type_name     | type_kind | typcategory | used_in_column_count |     enum_labels      
-- ------------------+-------------------+-----------+-------------+----------------------+----------------------
--  migration_v2_lab | order_status_enum | ENUM      | E           |                    0 | NEW, PAID, CANCELLED
-- (1 row)
-- 
-- SAMPLE_OUTPUT_END
