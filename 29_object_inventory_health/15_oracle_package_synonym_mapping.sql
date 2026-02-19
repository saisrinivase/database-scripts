/*
Purpose: Provide Oracle PACKAGE/SYNONYM migration mapping visibility in PostgreSQL.
Area: Object Inventory and Health
Usage: Use during migration assessments to validate replacement patterns.
*/
WITH routine_by_schema AS (
    SELECT
        n.nspname AS schema_name,
        count(*) FILTER (WHERE p.prokind = 'f')::bigint AS function_count,
        count(*) FILTER (WHERE p.prokind = 'p')::bigint AS procedure_count
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
    GROUP BY n.nspname
),
package_like AS (
    SELECT
        schema_name,
        function_count,
        procedure_count,
        (function_count + procedure_count) AS routine_total
    FROM routine_by_schema
    WHERE function_count + procedure_count > 0
),
synonym_like_views AS (
    SELECT
        n.nspname AS schema_name,
        c.relname AS view_name,
        pg_get_viewdef(c.oid, true) AS view_sql
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind = 'v'
      AND n.nspname !~ '^pg_'
      AND n.nspname <> 'information_schema'
)
SELECT
    'PACKAGE'::text AS oracle_object,
    'schema + function/procedure API grouping'::text AS postgres_mapping,
    count(*)::bigint AS candidate_count,
    'Use schema-scoped naming and grants to emulate package contracts.'::text AS recommendation,
    coalesce(string_agg(schema_name, ', ' ORDER BY schema_name), 'none') AS sample_objects
FROM (SELECT schema_name FROM package_like ORDER BY routine_total DESC, schema_name LIMIT 10) p
UNION ALL
SELECT
    'SYNONYM',
    'view or search_path aliasing pattern',
    count(*)::bigint,
    'Use views for stable aliases; avoid brittle global search_path changes.',
    coalesce(string_agg(format('%I.%I', schema_name, view_name), ', ' ORDER BY schema_name, view_name), 'none')
FROM (SELECT schema_name, view_name FROM synonym_like_views ORDER BY schema_name, view_name LIMIT 10) v
ORDER BY oracle_object;
