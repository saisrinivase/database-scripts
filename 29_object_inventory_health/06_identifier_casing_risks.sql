/*
Purpose: Find mixed/upper-case identifiers that require quoted SQL and increase migration risk.
Area: Object Inventory and Health
Usage: Standardize to lower_snake_case where possible for operational consistency.
*/
WITH rel_risks AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS object_name,
        CASE c.relkind
            WHEN 'r' THEN 'TABLE'
            WHEN 'p' THEN 'PARTITIONED_TABLE'
            WHEN 'v' THEN 'VIEW'
            WHEN 'm' THEN 'MVIEW'
            WHEN 'S' THEN 'SEQUENCE'
            WHEN 'i' THEN 'INDEX'
            ELSE c.relkind::text
        END AS object_type,
        format('%I.%I', n.nspname, c.relname) AS object_identity
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
      AND c.relkind IN ('r', 'p', 'v', 'm', 'S', 'i')
      AND c.relname ~ '[A-Z]'
),
column_risks AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS object_name,
        'COLUMN'::text AS object_type,
        format('%I.%I.%I', n.nspname, c.relname, a.attname) AS object_identity
    FROM pg_attribute a
    JOIN pg_class c ON c.oid = a.attrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
      AND c.relkind IN ('r', 'p', 'v', 'm')
      AND a.attnum > 0
      AND NOT a.attisdropped
      AND a.attname ~ '[A-Z]'
),
proc_risks AS (
    SELECT
        n.nspname AS schema_name,
        p.proname AS object_name,
        CASE p.prokind WHEN 'p' THEN 'PROCEDURE' ELSE 'FUNCTION' END AS object_type,
        format('%I.%I(%s)', n.nspname, p.proname, pg_get_function_identity_arguments(p.oid)) AS object_identity
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
      AND p.proname ~ '[A-Z]'
)
SELECT
    object_type,
    object_identity,
    'QUOTED_IDENTIFIER_REQUIRED' AS risk_flag,
    'Consider renaming to lower_snake_case to reduce query/tooling friction.' AS recommendation
FROM (
    SELECT * FROM rel_risks
    UNION ALL
    SELECT * FROM column_risks
    UNION ALL
    SELECT * FROM proc_risks
) x
ORDER BY object_type, object_identity;




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  object_type |           object_identity            |         risk_flag          |                             recommendation                              
-- -------------+--------------------------------------+----------------------------+-------------------------------------------------------------------------
--  INDEX       | migration_v1_lab."SalesOrders_pkey"  | QUOTED_IDENTIFIER_REQUIRED | Consider renaming to lower_snake_case to reduce query/tooling friction.
--  INDEX       | migration_v2_lab."QuotedOrders_pkey" | QUOTED_IDENTIFIER_REQUIRED | Consider renaming to lower_snake_case to reduce query/tooling friction.
-- (2 rows)
-- 
-- SAMPLE_OUTPUT_END
