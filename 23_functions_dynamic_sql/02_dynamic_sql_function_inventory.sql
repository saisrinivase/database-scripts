/*
Purpose: Inventory PL/pgSQL functions likely using dynamic SQL (EXECUTE keyword).
Area: Functions and Dynamic SQL
Usage: Review for SQL injection safety and plan stability.
*/
SELECT
    n.nspname AS schema_name,
    p.proname AS function_name,
    pg_get_function_identity_arguments(p.oid) AS function_args,
    l.lanname AS language_name,
    p.prosecdef AS security_definer,
    CASE WHEN p.prosrc ILIKE '%EXECUTE %' THEN true ELSE false END AS has_dynamic_sql
FROM pg_proc p
JOIN pg_namespace n
    ON n.oid = p.pronamespace
JOIN pg_language l
    ON l.oid = p.prolang
WHERE n.nspname !~ '^pg_'
  AND n.nspname <> 'information_schema'
  AND l.lanname = 'plpgsql'
  AND p.prosrc ILIKE '%EXECUTE %'
ORDER BY schema_name, function_name;
