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




-- SAMPLE_OUTPUT_BEGIN
-- Sample output captured from database: pgbench_test
-- Capture run directory: /tmp/pgbench_full_refresh_clean_20260218_194330
--
--  schema_name | function_name | function_args | language_name | security_definer | has_dynamic_sql 
-- -------------+---------------+---------------+---------------+------------------+-----------------
-- (0 rows)
-- 
-- 
-- Interpretation:
-- - No rows matched in this environment at capture time.
-- - This can be expected when the related object/feature is not present or not in use.
-- SAMPLE_OUTPUT_END
